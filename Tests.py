import math
import numpy as np


def fifth_root_newton(x, epsilon=1e-6):
    """
    Вычисление корня 5-й степени методом Ньютона
    """
    if x < 0:
        return -1  # Ошибка для отрицательных чисел

    if x == 0:
        return 0

    # Начальное приближение
    y = x / 5.0

    while True:
        # y_new = (4*y + x/y^4) / 5
        y_new = (4 * y + x / (y ** 4)) / 5

        # Проверка точности
        if abs(y_new - y) / abs(y) < epsilon:
            return y_new

        y = y_new


def fifth_root_pow(x):
    """
    Вычисление корня 5-й степени через степень
    """
    if x < 0:
        return -1
    return x ** (1 / 5)


def test_fifth_root():
    """
    Автоматизированное тестирование корня 5-й степени
    """
    test_cases = [
        (1, 1, "1"),
        (32, 2, "32"),
        (243, 3, "243"),
        (1024, 4, "1024"),
        (3125, 5, "3125"),
        (7776, 6, "7776"),
        (100000, 10, "100000"),
        (1048576, 16, "1048576")
    ]

    print("=" * 80)
    print("ТЕСТИРОВАНИЕ ВЫЧИСЛЕНИЯ КОРНЯ 5-Й СТЕПЕНИ")
    print("=" * 80)

    passed_tests = 0
    total_tests = len(test_cases)

    for i, (input_val, expected, desc) in enumerate(test_cases, 1):
        print(f"\nТест {i}: корень 5-й степени из {desc}")
        print("-" * 50)

        # Метод Ньютона (аналог ассемблерной реализации)
        result_newton = fifth_root_newton(input_val)

        # Стандартный метод Python
        result_pow = fifth_root_pow(input_val)

        # Метод NumPy
        result_numpy = np.power(input_val, 1 / 5)

        # Метод math.pow
        result_math = math.pow(input_val, 1 / 5) if input_val >= 0 else -1

        print(f"Ожидаемый результат: {expected:.6f}")
        print(f"Метод Ньютона:       {result_newton:.6f}")
        print(f"Python (оператор **): {result_pow:.6f}")
        print(f"NumPy:               {result_numpy:.6f}")
        print(f"Math.pow:            {result_math:.6f}")

        # Проверка точности (допуск 1%)
        tolerance = 0.01
        newton_error = abs(result_newton - expected) / expected
        pow_error = abs(result_pow - expected) / expected
        numpy_error = abs(result_numpy - expected) / expected
        math_error = abs(result_math - expected) / expected

        print(f"Погрешности:")
        print(f"  Метод Ньютона: {newton_error:.6f} ({newton_error * 100:.3f}%)")
        print(f"  Python **:     {pow_error:.6f} ({pow_error * 100:.3f}%)")
        print(f"  NumPy:         {numpy_error:.6f} ({numpy_error * 100:.3f}%)")
        print(f"  Math.pow:      {math_error:.6f} ({math_error * 100:.3f}%)")

        # Проверяем, что все методы дают корректный результат
        if (newton_error < tolerance and pow_error < tolerance and
                numpy_error < tolerance and math_error < tolerance):
            print("✓ ТЕСТ ПРОЙДЕН")
            passed_tests += 1
        else:
            print("✗ ТЕСТ НЕ ПРОЙДЕН")

    # Тест с отрицательным числом
    print(f"\nТест с отрицательным числом:")
    print("-" * 50)
    negative_result = fifth_root_newton(-10)
    print(f"Вход: -10")
    print(f"Результат метода Ньютона: {negative_result}")
    print(f"Ожидаемый: -1 (код ошибки)")

    if negative_result == -1:
        print("✓ Обработка ошибки корректна")
        passed_tests += 1
    else:
        print("✗ Ошибка в обработке отрицательных чисел")

    total_tests += 1  # Добавляем тест с ошибкой

    # Итоги
    print("\n" + "=" * 80)
    print(f"ИТОГИ ТЕСТИРОВАНИЯ:")
    print(f"Пройдено тестов: {passed_tests}/{total_tests}")
    print(f"Успешность: {passed_tests / total_tests * 100:.1f}%")
    print("=" * 80)


def performance_comparison():
    """
    Сравнение производительности различных методов
    """
    print("\n\n" + "=" * 80)
    print("СРАВНЕНИЕ ПРОИЗВОДИТЕЛЬНОСТИ")
    print("=" * 80)

    test_values = [1, 32, 243, 1024, 3125, 7776, 100000, 1048576]

    import time

    # Метод Ньютона
    start_time = time.time()
    for val in test_values * 1000:  # Многократное повторение для точности
        fifth_root_newton(val)
    newton_time = time.time() - start_time

    # Python оператор **
    start_time = time.time()
    for val in test_values * 1000:
        fifth_root_pow(val)
    pow_time = time.time() - start_time

    # NumPy
    start_time = time.time()
    for val in test_values * 1000:
        np.power(val, 1 / 5)
    numpy_time = time.time() - start_time

    # Math.pow
    start_time = time.time()
    for val in test_values * 1000:
        math.pow(val, 1 / 5) if val >= 0 else -1
    math_time = time.time() - start_time

    print(f"Метод Ньютона:  {newton_time:.4f} сек")
    print(f"Python **:      {pow_time:.4f} сек")
    print(f"NumPy:          {numpy_time:.4f} сек")
    print(f"Math.pow:       {math_time:.4f} сек")


def additional_accuracy_tests():
    """
    Дополнительные тесты на точность
    """
    print("\n\n" + "=" * 80)
    print("ДОПОЛНИТЕЛЬНЫЕ ТЕСТЫ НА ТОЧНОСТЬ")
    print("=" * 80)

    # Тесты с очень большими числами
    large_numbers = [
        (10 ** 10, 100),  # 100^5 = 10^10
        (10 ** 15, 1000),  # 1000^5 = 10^15
        (2 ** 50, 2 ** 10),  # (2^10)^5 = 2^50
    ]

    print("Тесты с большими числами:")
    for input_val, expected in large_numbers:
        result_newton = fifth_root_newton(input_val)
        result_pow = fifth_root_pow(input_val)

        newton_error = abs(result_newton - expected) / expected
        pow_error = abs(result_pow - expected) / expected

        print(f"\nВход: {input_val:.2e}")
        print(f"Ожидаемый: {expected}")
        print(f"Ньютон: {result_newton:.6f} (погр.: {newton_error * 100:.6f}%)")
        print(f"Python: {result_pow:.6f} (погр.: {pow_error * 100:.6f}%)")

    # Тесты с очень маленькими числами
    small_numbers = [
        (1e-10, 1e-2),  # (1e-2)^5 = 1e-10
        (1e-15, 1e-3),  # (1e-3)^5 = 1e-15
    ]

    print("\nТесты с маленькими числами:")
    for input_val, expected in small_numbers:
        result_newton = fifth_root_newton(input_val)
        result_pow = fifth_root_pow(input_val)

        newton_error = abs(result_newton - expected) / expected
        pow_error = abs(result_pow - expected) / expected

        print(f"\nВход: {input_val:.2e}")
        print(f"Ожидаемый: {expected}")
        print(f"Ньютон: {result_newton:.6e} (погр.: {newton_error * 100:.6f}%)")
        print(f"Python: {result_pow:.6e} (погр.: {pow_error * 100:.6f}%)")


if __name__ == "__main__":
    # Основное тестирование
    test_fifth_root()

    # Сравнение производительности
    performance_comparison()

    # Дополнительные тесты на точность
    additional_accuracy_tests()

    # Демонстрация работы в интерактивном режиме
    print("\n\n" + "=" * 80)
    print("ИНТЕРАКТИВНЫЙ РЕЖИМ")
    print("=" * 80)

    while True:
        try:
            user_input = input("\nВведите число для вычисления корня 5-й степени (или 'q' для выхода): ")
            if user_input.lower() == 'q':
                break

            number = float(user_input)

            if number < 0:
                print("Ошибка: введите положительное число")
                continue

            result_newton = fifth_root_newton(number)
            result_python = fifth_root_pow(number)

            print(f"Корень 5-й степени из {number}:")
            print(f"  Метод Ньютона: {result_newton:.10f}")
            print(f"  Python:        {result_python:.10f}")
            print(f"  Разность:      {abs(result_newton - result_python):.2e}")

        except ValueError:
            print("Ошибка: введите корректное число")
        except KeyboardInterrupt:
            print("\nВыход из программы")
            break