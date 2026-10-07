import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/main.dart';

Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  final scrollable = find.byType(SingleChildScrollView).first;
  final screenHeight =
      tester.view.physicalSize.height / tester.view.devicePixelRatio;
  final bottomLimit = screenHeight - 96;

  for (var i = 0; i < 12; i++) {
    final rect = tester.getRect(finder);
    if (rect.top >= 0 && rect.bottom <= bottomLimit) {
      return;
    }

    final dy = rect.top < 0 ? 350.0 : -350.0;
    await tester.drag(scrollable, Offset(0, dy));
    await tester.pumpAndSettle();
  }
}

void main() {
  test('builds registration summary with all selected values', () {
    const registration = CourseRegistration(
      fullName: 'Nguyen Duc Quang',
      studentId: '2312900250',
      faculty: 'Cong nghe thong tin',
      course: 'Lap trinh tren cac thiet bi di dong',
      program: 'Chinh quy',
      sessions: ['Sang', 'Toi'],
      emailNotification: true,
      priorityMode: true,
    );

    expect(registration.summary, contains('Ho ten: Nguyen Duc Quang'));
    expect(registration.summary, contains('MSSV: 2312900250'));
    expect(registration.summary, contains('Buoi hoc: Sang, Toi'));
    expect(registration.summary, contains('Che do uu tien: Bat'));
  });

  testWidgets('validates empty name before submitting', (tester) async {
    await tester.pumpWidget(const MyApp());

    await scrollTo(tester, find.byKey(const Key('confirmButton')));
    await tester.tap(find.byKey(const Key('confirmButton')));
    await tester.pump();

    expect(find.text('Khong duoc de trong'), findsOneWidget);
    expect(find.text('Xac nhan dang ky'), findsNothing);
  });

  testWidgets('validates student id length', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byKey(const Key('nameField')), 'Nguyen A');
    await tester.enterText(find.byKey(const Key('studentIdField')), '12345');
    await scrollTo(tester, find.byKey(const Key('confirmButton')));
    await tester.tap(find.byKey(const Key('confirmButton')));
    await tester.pump();

    expect(find.text('MSSV phai gom dung 10 chu so'), findsOneWidget);
  });

  testWidgets('requires program before submitting', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byKey(const Key('nameField')), 'Nguyen A');
    await tester.enterText(
      find.byKey(const Key('studentIdField')),
      '1234567890',
    );
    await scrollTo(tester, find.byKey(const Key('confirmButton')));
    await tester.tap(find.byKey(const Key('confirmButton')));
    await tester.pump();

    expect(find.text('Vui long chon he dao tao'), findsOneWidget);
  });

  testWidgets('requires at least one selected session', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byKey(const Key('nameField')), 'Nguyen A');
    await tester.enterText(
      find.byKey(const Key('studentIdField')),
      '1234567890',
    );

    await scrollTo(tester, find.text('Chinh quy'));
    await tester.tap(find.text('Chinh quy'));
    await tester.pump();
    await scrollTo(tester, find.byKey(const Key('confirmButton')));
    await tester.tap(find.byKey(const Key('confirmButton')));
    await tester.pump();

    expect(find.text('Vui long chon it nhat mot buoi hoc'), findsOneWidget);
  });

  testWidgets('submits valid form and returns to edit screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(
      find.byKey(const Key('nameField')),
      'Nguyen Duc Quang',
    );
    await tester.enterText(
      find.byKey(const Key('studentIdField')),
      '2312900250',
    );
    await scrollTo(tester, find.text('Chinh quy'));
    await tester.tap(find.text('Chinh quy'));
    await scrollTo(tester, find.byKey(const Key('morningCheckbox')));
    await tester.tap(find.byKey(const Key('morningCheckbox')));
    await scrollTo(tester, find.byKey(const Key('eveningCheckbox')));
    await tester.tap(find.byKey(const Key('eveningCheckbox')));
    await tester.pump();

    expect(find.text('Da chon 2 buoi hoc'), findsOneWidget);

    await scrollTo(tester, find.text('UU TIEN: BAT'));
    await tester.tap(find.text('UU TIEN: BAT'));
    await scrollTo(tester, find.byKey(const Key('confirmButton')));
    await tester.tap(find.byKey(const Key('confirmButton')));
    await tester.pumpAndSettle();

    expect(find.text('Xac nhan dang ky'), findsWidgets);
    expect(find.textContaining('Ho ten: Nguyen Duc Quang'), findsOneWidget);
    expect(find.textContaining('MSSV: 2312900250'), findsOneWidget);
    expect(find.textContaining('Buoi hoc: Sang, Toi'), findsOneWidget);

    await tester.tap(find.byKey(const Key('editButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('nameField')), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Nguyen Duc Quang'),
      findsOneWidget,
    );
  });

  testWidgets('reset restores initial values', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byKey(const Key('nameField')), 'Nguyen A');
    await tester.enterText(
      find.byKey(const Key('studentIdField')),
      '1234567890',
    );
    await scrollTo(tester, find.text('Chinh quy'));
    await tester.tap(find.text('Chinh quy'));
    await scrollTo(tester, find.byKey(const Key('morningCheckbox')));
    await tester.tap(find.byKey(const Key('morningCheckbox')));
    await tester.pump();

    expect(find.text('Da chon 1 buoi hoc'), findsOneWidget);

    await scrollTo(tester, find.byKey(const Key('resetButton')));
    await tester.tap(find.byKey(const Key('resetButton')));
    await tester.pump();

    expect(find.text('Da chon 0 buoi hoc'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Nguyen A'), findsNothing);
  });
}
