/// A generic function type that takes a value of type [T] and returns nothing.
typedef OnChanged<T> = void Function(T value);

/// A type alias for a JSON object, which is a map of string keys to dynamic values.
typedef Json = Map<String, dynamic>;