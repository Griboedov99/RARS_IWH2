.include "macros.asm"

.data
test_passed_msg: .asciz "Test passed: "
test_failed_msg: .asciz "Test failed: "
expected_msg: .asciz " expected: "
got_msg: .asciz " got: "

input_prompt: .asciz "Enter a number to calculate 5th root: "
result_msg: .asciz "5th root: "
error_msg: .asciz "Error: input must be positive!\n"
testing_msg: .asciz "Running fifth root tests...\n"
error_test_msg: .asciz "Testing error case (negative input)...\n"
error_test_passed_msg: .asciz "Error test passed: correctly handled negative input\n"
error_test_failed_msg: .asciz "Error test failed!\n"

# Константы с плавающей точкой
const_4:    .float 4.0
const_1:    .float 1.0  
epsilon:    .float 0.001   # 0.1% точность
const_5:    .float 5.0
const_neg1: .float -1.0
const_001:  .float 0.01    # допуск для тестов 1%

.text

# =============================================
# Подпрограмма вычисления корня 5-й степени
# a0 - входное число (целое)
# fa0 - результат (корень 5-й степени)
# =============================================
fifth_root:
    # Сохраняем регистры
    addi sp, sp, -12
    sw ra, 8(sp)
    sw s0, 4(sp)
    sw s1, 0(sp)
    
    # Проверка на положительное число
    li t0, 0
    ble a0, t0, fifth_root_error
    
    # Инициализация
    fcvt.s.w f0, a0        # f0 = x (преобразуем в float)
    li t0, 5               # n = 5
    fcvt.s.w f1, t0        # f1 = 5.0
    
    # Загружаем константы из памяти
    la t0, const_4
    flw f3, 0(t0)          # 4.0
    la t0, const_1
    flw f4, 0(t0)          # 1.0
    la t0, epsilon
    flw f5, 0(t0)          # точность 0.1%
    
    # Начальное приближение: y0 = x / 5
    fdiv.s f2, f0, f1      # f2 = y (текущее приближение)
    
fifth_root_loop:
    # y^(n-1) = y^4
    fmul.s f6, f2, f2      # y^2
    fmul.s f6, f6, f6      # y^4
    
    # (n-1)*y^(n-1) = 4*y^4
    fmul.s f6, f6, f3      # 4*y^4
    
    # y^n = y^4 * y = y^5
    fmul.s f7, f6, f2      # y^5 (f6 уже содержит 4*y^4)
    fdiv.s f7, f7, f3      # y^5 (делим на 4 чтобы получить y^5)
    
    # Вычисление нового приближения:
    # y_new = ((n-1)*y + x/y^(n-1)) / n
    # = (4*y + x/y^4) / 5
    
    # x / y^4
    fmul.s f8, f2, f2      # y^2
    fmul.s f8, f8, f8      # y^4
    fdiv.s f8, f0, f8      # x / y^4
    
    # 4*y + x/y^4
    fmul.s f9, f2, f3      # 4*y
    fadd.s f9, f9, f8      # 4*y + x/y^4
    
    # y_new = (4*y + x/y^4) / 5
    fdiv.s f10, f9, f1     # новое приближение
    
    # Проверка точности: |y_new - y| / y < epsilon
    fsub.s f11, f10, f2    # разность
    fabs.s f11, f11        # модуль разности
    fdiv.s f11, f11, f2    # относительная ошибка
    
    # Переходим к новому приближению
    fmv.s f2, f10
    
    # Проверяем условие выхода
    flt.s t1, f11, f5      # если ошибка < epsilon
    beqz t1, fifth_root_loop
    
    # Возвращаем результат
    fmv.s fa0, f2
    
    # Восстанавливаем регистры
    lw s1, 0(sp)
    lw s0, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 12
    ret

fifth_root_error:
    # Ошибка - отрицательное число
    la t0, const_neg1
    flw fa0, 0(t0)
    lw s1, 0(sp)
    lw s0, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 12
    ret

# =============================================
# Подпрограмма вывода float
# fa0 - число для вывода
# =============================================
print_float:
    addi sp, sp, -8
    sw a0, 4(sp)
    sw a7, 0(sp)
    
    li a7, 2
    ecall
    
    lw a7, 0(sp)
    lw a0, 4(sp)
    addi sp, sp, 8
    ret

# =============================================
# Подпрограмма тестирования
# a0 - входное число
# a1 - ожидаемый результат (целое)
# a2 - номер теста
# =============================================
test_fifth_root_proc:
    addi sp, sp, -32
    sw ra, 28(sp)
    sw a0, 24(sp)
    sw a1, 20(sp)
    sw a2, 16(sp)
    sw t0, 12(sp)
    fsw fs0, 8(sp)
    fsw fs1, 4(sp)
    fsw fs2, 0(sp)
    
    # Вычисляем корень
    call fifth_root
    fmv.s fs0, fa0          # сохраняем результат
    
    # Ожидаемый результат
    lw a1, 20(sp)
    fcvt.s.w fs1, a1        # преобразуем ожидаемый результат в float
    
    # Проверяем разность (допуск 0.01 = 1%)
    fsub.s fs2, fs0, fs1    # разность
    fabs.s fs2, fs2         # модуль разности
    la t0, const_001
    flw ft0, 0(t0)          # загружаем допуск
    flt.s t0, fs2, ft0      # сравниваем
    
    # Выводим результат теста
    lw a2, 16(sp)
    bnez t0, test_passed_proc
    
    # Тест не пройден
    la a0, test_failed_msg
    li a7, 4
    ecall
    
    lw a0, 16(sp)          # номер теста
    li a7, 1
    ecall
    
    la a0, expected_msg
    li a7, 4
    ecall
    
    lw a0, 24(sp)          # входное число
    li a7, 1
    ecall
    
    la a0, expected_msg
    li a7, 4
    ecall
    
    lw a0, 20(sp)          # ожидаемый результат
    li a7, 1
    ecall
    
    la a0, got_msg
    li a7, 4
    ecall
    
    fmv.s fa0, fs0         # полученный результат
    call print_float
    
    call newline
    j test_end_proc
    
test_passed_proc:
    # Тест пройден
    la a0, test_passed_msg
    li a7, 4
    ecall
    
    lw a0, 16(sp)          # номер теста
    li a7, 1
    ecall
    
    la a0, expected_msg
    li a7, 4
    ecall
    
    lw a0, 24(sp)          # входное число
    li a7, 1
    ecall
    
    la a0, expected_msg
    li a7, 4
    ecall
    
    lw a0, 20(sp)          # ожидаемый результат
    li a7, 1
    ecall
    
    la a0, got_msg
    li a7, 4
    ecall
    
    fmv.s fa0, fs0         # полученный результат
    call print_float
    
    call newline
    
test_end_proc:
    flw fs2, 0(sp)
    flw fs1, 4(sp)
    flw fs0, 8(sp)
    lw t0, 12(sp)
    lw a2, 16(sp)
    lw a1, 20(sp)
    lw a0, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32
    ret

# =============================================
# Автоматизированное тестирование
# =============================================
run_tests:
    addi sp, sp, -8
    sw ra, 4(sp)
    sw s0, 0(sp)
    
    # Сообщение о начале тестирования
    la a0, testing_msg
    li a7, 4
    ecall
    
    # Тест 1: корень из 1
    li a0, 1
    li a1, 1
    li a2, 1
    call test_fifth_root_proc
    
    # Тест 2: корень из 32
    li a0, 32
    li a1, 2
    li a2, 2
    call test_fifth_root_proc
    
    # Тест 3: корень из 243
    li a0, 243
    li a1, 3
    li a2, 3
    call test_fifth_root_proc
    
    # Тест 4: корень из 1024
    li a0, 1024
    li a1, 4
    li a2, 4
    call test_fifth_root_proc
    
    # Тест 5: корень из 3125
    li a0, 3125
    li a1, 5
    li a2, 5
    call test_fifth_root_proc
    
    # Тест 6: корень из 7776
    li a0, 7776
    li a1, 6
    li a2, 6
    call test_fifth_root_proc
    
    # Тест 7: корень из 100000
    li a0, 100000
    li a1, 10
    li a2, 7
    call test_fifth_root_proc
    
    # Тест 8: корень из 1048576
    li a0, 1048576
    li a1, 16
    li a2, 8
    call test_fifth_root_proc
    
    # Тест с ошибкой: отрицательное число
    la a0, error_test_msg
    li a7, 4
    ecall
    
    li a0, -10
    call fifth_root
    la t0, const_neg1
    flw ft1, 0(t0)
    feq.s t0, fa0, ft1
    bnez t0, error_test_passed
    
    la a0, error_test_failed_msg
    li a7, 4
    ecall
    j error_test_end
    
error_test_passed:
    la a0, error_test_passed_msg
    li a7, 4
    ecall
    
error_test_end:
    lw s0, 0(sp)
    lw ra, 4(sp)
    addi sp, sp, 8
    ret

# =============================================
# Новая строка (замена макроса)
# =============================================
newline:
    addi sp, sp, -8
    sw a0, 4(sp)
    sw a7, 0(sp)
    li a7, 11
    li a0, 10
    ecall
    lw a7, 0(sp)
    lw a0, 4(sp)
    addi sp, sp, 8
    ret

# =============================================
# Основная программа
# =============================================
.globl main
main:
    # Запускаем тесты
    call run_tests
    call newline
    
    # Интерактивный режим
interactive_loop:
    # Вывод приглашения
    la a0, input_prompt
    li a7, 4
    ecall
    
    # Ввод числа
    li a7, 5
    ecall
    
    # Проверяем на 0 (выход)
    beqz a0, exit_program
    
    # Проверяем на отрицательное число
    blt a0, zero, input_error
    
    # Сохраняем ввод
    mv s0, a0
    
    # Вычисляем корень
    call fifth_root
    
    # Сохраняем результат
    fmv.s fs0, fa0
    
    # Выводим сообщение о результате
    la a0, result_msg
    li a7, 4
    ecall
    
    # Выводим результат
    fmv.s fa0, fs0
    call print_float
    call newline
    
    j interactive_loop

input_error:
    la a0, error_msg
    li a7, 4
    ecall
    j interactive_loop

exit_program:
    # Выход из программы
    li a7, 10
    ecall