# 13 - Tests Bloc whenState

Consider a cubit of the form (taken from flutter_bloc)

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}
```

When mocking this cubit (i.e. in a widget test), both the state and the stream need to be given values:

```dart
when(() => mockCounterCubit.state).thenReturn(0);
whenListen(mockCounterCubit, Stream.value(0));
```

If the state remains constant for a test, one simplification is to define `whenState`:

```dart
void whenState<State>(
  BlocBase<State> bloc,
  State state,
) {
  whenListen(bloc, Stream.value(state));
  when(() => bloc.state).thenReturn(state);
}
```

which can be used as follows:

```dart
whenState(mockCounterCubit, 0);
```

This can be useful to reduce copy-paste setup code.
