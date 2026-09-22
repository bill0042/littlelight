abstract class BaseFilterOptions<T> {
  T _value;
  set value(T value) => _value = value;
  T get value => _value;

  T _availableValues;
  T get availableValues => _availableValues;
  set availableValues(T values) => _availableValues = values;

  bool _enabled;
  bool get enabled => _enabled;
  set enabled(bool value) => _enabled = value;

  bool get available => true;

  BaseFilterOptions(this._value, {required T availableValues, bool enabled = false})
    : _availableValues = availableValues,
      _enabled = enabled;
}

abstract class BaseDiscreteFilterOptions<T> extends BaseFilterOptions<Set<T>> {
  Set<T> _exclude = {};

  set include(Set<T> value) => _value = value;
  Set<T> get include => _value;
  set exclude(Set<T> value) => _exclude = value;
  Set<T> get exclude => _exclude;
  bool get isEmpty => include.isEmpty && exclude.isEmpty;

  bool isSelected(T? value) {
    if (include.isNotEmpty && !include.contains(value)) return false;
    if (exclude.contains(value)) return false;
    return true;
  }

  // check if any value is included and no values are excluded
  bool anySelected(Set<T>? values) {
    final safeValues = values ?? const {};
    if (safeValues.isEmpty) return include.isEmpty;
    if (safeValues.any(exclude.contains)) return false;
    if (include.isNotEmpty) return safeValues.any(include.contains);
    return true;
  }

  @override
  bool get available => _availableValues.length > 1;

  BaseDiscreteFilterOptions(value, {required availableValues, enabled})
    : super(value, availableValues: availableValues, enabled: enabled = false);
}
