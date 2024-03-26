import 'package:flutter/widgets.dart' hide Action, Page;

import '../redux/redux.dart';
import 'basic.dart';

class _Dependent<T, P> implements Dependent<T> {
  final AbstractConnector<T, P> connector;
  final AbstractLogic<P> logic;

  _Dependent({
    required this.logic,
    required this.connector,
  });

  @override
  SubReducer<T>? createSubReducer() {
    final Reducer<P>? reducer = logic.reducer;
    return reducer != null ? connector.subReducer(reducer) : null;
  }

  @override
  Widget buildComponent(
    Store<Object?> store,
    Get<T> getter, {
    required DispatchBus bus,
    required Enhancer<Object?> enhancer,
  }) {
    assert(isComponent(), 'Unexpected type of ${logic.runtimeType}.');
    final AbstractComponent<P> component = logic as AbstractComponent<P>;
    return component.buildComponent(
      store,
      () => connector.get(getter()),
      bus: bus,
      enhancer: enhancer,
    );
  }

  @override
  ListAdapter buildAdapter(covariant ContextSys<P?> ctx) {
    assert(isAdapter(), 'Unexpected type of ${logic.runtimeType}.');
    final AbstractAdapter<P?> adapter = logic as AbstractAdapter<P?>;
    return adapter.buildAdapter(ctx);
  }

  @override
  Get<P> subGetter(Get<T> getter) => () => connector.get(getter());

  @override
  bool isComponent() => logic is AbstractComponent;

  @override
  bool isAdapter() => logic is AbstractAdapter;

  @override
  ContextSys<Object> createContext(
      Store<Object?> store, BuildContext buildContext, Get<T> getState,
      {DispatchBus? bus, Enhancer<Object?>? enhancer}) {
    return logic.createContext(
      store,
      buildContext,
      subGetter(getState),
      bus: bus,
      enhancer: enhancer,
    ) as ContextSys<Object>;
  }
}

Dependent<K> createDependent<K, T>(
        AbstractConnector<K, T> connector, AbstractLogic<T> logic) =>
    _Dependent<K, T>(connector: connector, logic: logic);
