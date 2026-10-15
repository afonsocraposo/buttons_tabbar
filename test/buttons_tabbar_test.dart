import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

List<Tab> _tabs(int n) => [for (var i = 0; i < n; i++) Tab(text: 'tab$i')];

void main() {
  testWidgets('works with material_ui DefaultTabController', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DefaultTabController(
          length: 3,
          child: Column(children: [
            ButtonsTabBar(tabs: _tabs(3)),
            Expanded(
              child: TabBarView(children: [
                for (var i = 0; i < 3; i++) Text('page$i'),
              ]),
            ),
          ]),
        ),
      ),
    ));

    expect(find.text('page0'), findsOneWidget);
    await tester.tap(find.text('tab2'));
    await tester.pumpAndSettle();
    expect(find.text('page2'), findsOneWidget);
  });

  testWidgets('accepts a material_ui TabController and scrolls to off-screen tab',
      (tester) async {
    final controller = TabController(length: 20, vsync: const TestVSync());
    addTearDown(controller.dispose);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ButtonsTabBar(controller: controller, tabs: _tabs(20)),
      ),
    ));

    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    expect(tester.getRect(find.text('tab19')).left, greaterThan(width));
    controller.animateTo(19);
    await tester.pumpAndSettle();
    expect(controller.index, 19);
    expect(tester.getRect(find.text('tab19')).right, lessThanOrEqualTo(width));
  });
}
