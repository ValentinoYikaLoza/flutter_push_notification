import 'package:flutter/services.dart';

enum ValidatorsWydnex {
  required,
  firstName,
  lastName,
  email,
  password,
  phone,
  dni,
  ruc,
  code,
  date,
  url,
  comment,
  exactLength,
  minLength,
  maxLength,
  match,
  contains,
  equal,
  lessThan,
  greaterThan,
  pattern,
  onlyNumbers,
  custom,
}

class ValidatorWydnex {
  final ValidatorsWydnex type;
  final dynamic value;
  final String? errorMessage; // Valor dinámico para los parámetros

  const ValidatorWydnex(this.type, {this.value, this.errorMessage});
}

class FormatterWydnex {
  final TextInputFormatter type;
  final dynamic value;

  const FormatterWydnex(this.type, {this.value});
}

class FormWydnex<T> {
  const FormWydnex({
    required this.value,
    this.validators = const [],
    this.formatters = const [],
    this.isTouched = false,
  });

  final T value;
  final List<ValidatorWydnex> validators;
  final List<TextInputFormatter> formatters;
  final bool isTouched;

  bool get isValid => errorMessage == null;

  bool get isInvalid => errorMessage != null;

  String? get errorMessage {
    for (var validator in validators) {
      switch (validator.type) {
        case ValidatorsWydnex.required:
          if (value == '') {
            return 'Este campo es requerido';
          }
          break;
        case ValidatorsWydnex.firstName:
          if (!RegExp(r"^[a-zA-ZÀ-ÿ']+(\s[a-zA-ZÀ-ÿ']+)*$")
              .hasMatch(value.toString())) {
            return 'Ingrese un nombre válido (solo letras y espacios)';
          }
          break;
        case ValidatorsWydnex.lastName:
          if (!RegExp(r"^[a-zA-ZÀ-ÿ']+(\s[a-zA-ZÀ-ÿ']+)*$")
              .hasMatch(value.toString())) {
            return 'Ingrese un apellido válido';
          }
          break;
        case ValidatorsWydnex.email:
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
              .hasMatch(value.toString())) {
            return 'Ingrese un correo electrónico válido (por ejemplo, example@example.com)';
          }
          break;
        case ValidatorsWydnex.password:
          if (!RegExp(
                  r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$%\^&\*])(?=.{12,})')
              .hasMatch(value.toString())) {
            return 'La contraseña debe tener al menos 12 caracteres y contener al menos una letra mayúscula, \nuna letra minúscula, un número y un carácter especial (por ejemplo, Q7PQ^ThLS/TH@C3x{Hfqxg6)';
          }
          break;
        case ValidatorsWydnex.phone:
          if (!RegExp(r'^\+\d{9,14}$').hasMatch(value.toString())) {
            return 'Ingrese un número de teléfono válido (por ejemplo, +51123456789)';
          }
          break;
        case ValidatorsWydnex.dni:
          if (!RegExp(r'^[0-9]{8}$').hasMatch(value.toString())) {
            return 'El DNI debe tener exactamente 8 dígitos (por ejemplo, 12345678)';
          }
          break;
        case ValidatorsWydnex.ruc:
          if (!RegExp(r'^[0-9]{11}$').hasMatch(value.toString())) {
            return 'El RUC debe tener exactamente 11 dígitos (por ejemplo, 12345678901)';
          }
          break;
        case ValidatorsWydnex.code:
          if (!RegExp(r'^[A-Z0-9]{5}[-]?[A-Z0-9]{5}[-]?[A-Z0-9]{5}$')
              .hasMatch(value.toString())) {
            return 'Ingrese un código válido con el formato especificado (por ejemplo, KTHJ6-IJ0C6-WK9VN)';
          }
          break;
        case ValidatorsWydnex.date:
          final RegExp dateRegex = RegExp(
            r'^([0-2][0-9]|3[0-1])/(0[1-9]|1[0-2])/(19|20)\d{2}$',
          );

          if (!dateRegex.hasMatch(value.toString())) {
            return 'Ingrese una fecha válida (formato: dd/mm/yyyy)';
          }

          final List<String> parts = value.toString().split('/');
          final int day = int.parse(parts[0]);
          final int month = int.parse(parts[1]);
          final int year = int.parse(parts[2]);

          if (year < 1900 || year > DateTime.now().year) {
            return 'Ingrese un año válido (entre 1900 y ${DateTime.now().year})';
          }

          if (month < 1 || month > 12) {
            return 'Ingrese un mes válido (entre 01 y 12)';
          }

          bool isLeapYear(int year) {
            if (year % 4 != 0) {
              return false;
            } else if (year % 100 != 0) {
              return true;
            } else if (year % 400 != 0) {
              return false;
            } else {
              return true;
            }
          }

          switch (month) {
            case 2:
              if (isLeapYear(year)) {
                if (day < 1 || day > 29) {
                  return 'Ingrese un día válido para febrero (año bisiesto)';
                }
              } else {
                if (day < 1 || day > 28) {
                  return 'Ingrese un día válido para febrero (entre 01 y 28)';
                }
              }
              break;
            case 4:
            case 6:
            case 9:
            case 11:
              if (day < 1 || day > 30) {
                return 'Ingrese un día válido para este mes (entre 01 y 30)';
              }
              break;
            default:
              if (day < 1 || day > 31) {
                return 'Ingrese un día válido para este mes (entre 01 y 31)';
              }
          }
          break;
        case ValidatorsWydnex.url:
          if (!RegExp(
                  r'^(?:http|https)?://(?:(?:[a-zA-Z0-9-]+\.)*[a-zA-Z0-9-]+)+(?:/[\w-]+)*\??(?:[\w-]+=[\w-]+&?)*$')
              .hasMatch(value.toString())) {
            return 'Ingrese una URL válida (por ejemplo, http://www.ejemplo.com)';
          }
          break;
        case ValidatorsWydnex.exactLength:
          final exactLength =
              validator.value as int; // Obtener el valor mínimo del validador
          if (value.toString().length != exactLength) {
            return validator.errorMessage ??
                'Debe tener $exactLength caracteres';
          }
          break;
        case ValidatorsWydnex.minLength:
          final minLength =
              validator.value as int; // Obtener el valor mínimo del validador
          if (value.toString().length < minLength) {
            return validator.errorMessage ??
                'Debe tener al menos $minLength caracteres';
          }
          break;
        case ValidatorsWydnex.maxLength:
          final maxLength = validator.value
              as int; // Obtener la longitud máxima del validador
          if (value.toString().length > maxLength) {
            return 'Debe tener como máximo $maxLength caracteres';
          }
          break;
        case ValidatorsWydnex.onlyNumbers:
          if (!RegExp(r'^[0-9]+$').hasMatch(value.toString())) {
            return 'Ingrese solo números';
          }
          break;
        case ValidatorsWydnex.match:
          final expectedValue = validator.value;
          if (value != expectedValue) {
            return 'El valor debe ser igual a $expectedValue';
          }
          break;
        case ValidatorsWydnex.contains:
          final charToContain = validator.value;
          if (!value.toString().contains(charToContain)) {
            return 'El valor debe contener el carácter $charToContain';
          }
          break;
        case ValidatorsWydnex.equal:
          final expectedValue = validator.value;
          try {
            if (int.parse(value.toString()) != expectedValue) {
              return 'El valor debe ser igual a $expectedValue';
            }
          } catch (e) {
            return 'El valor debe ser un número';
          }

        case ValidatorsWydnex.lessThan:
          final expectedValue = validator.value;
          try {
            if (int.parse(value.toString()) >= expectedValue) {
              return 'El valor debe ser menor a $expectedValue';
            }
          } catch (e) {
            return 'El valor debe ser un número';
          }

          break;
        case ValidatorsWydnex.greaterThan:
          final expectedValue = validator.value;
          try {
            if (int.parse(value.toString()) <= expectedValue) {
              return 'El valor debe ser mayor a $expectedValue';
            }
          } catch (e) {
            return 'El valor debe ser un número';
          }

        case ValidatorsWydnex.pattern:
          final pattern =
              validator.value as String; // Obtener el patrón del validador
          if (!RegExp(pattern).hasMatch(value.toString())) {
            return 'El valor no cumple con el patrón especificado';
          }
          break;
        case ValidatorsWydnex.custom:
          final customValidator = validator.value as String? Function(
              T); // Obtener la función del validador personalizado
          final errorMessage = customValidator(
              value); // Ejecutar la función para obtener el mensaje de error
          return errorMessage; // Retornar el mensaje de error obtenido
        default:
          break;
      }
    }

    return null;
  }

  FormWydnex<T> touch() {
    return copyWith(
      isTouched: true,
    );
  }

  FormWydnex<T> setValue(T newValue) {
    return copyWith(
      value: newValue,
    );
  }

  FormWydnex<T> copyWith({
    bool? isTouched,
    T? value,
  }) =>
      FormWydnex<T>(
        isTouched: isTouched ?? this.isTouched,
        validators: this.validators,
        formatters: this.formatters,
        value: value ?? this.value,
      );
}
