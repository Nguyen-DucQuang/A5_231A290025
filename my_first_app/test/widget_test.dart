import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/main.dart';

void main() {
  test('copies contact values with copyWith', () {
    const contact = Contact(
      fullName: 'Nguyen Van A',
      phone: '0909123456',
      email: 'a@example.com',
    );

    final updated = contact.copyWith(fullName: 'Tran Thi B');

    expect(updated.fullName, 'Tran Thi B');
    expect(updated.phone, '0909123456');
    expect(updated.email, 'a@example.com');
  }); 

  testWidgets('opens detail screen and returns updated contact', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byKey(const Key('nameField')), 'Nguyen Van A');
    await tester.enterText(find.byKey(const Key('phoneField')), '0909123456');
    await tester.enterText(
      find.byKey(const Key('emailField')),
      'a@example.com',
    );
    await tester.tap(find.byKey(const Key('openDetailButton')));
    await tester.pumpAndSettle();

    expect(find.text('Chi tiết liên hệ'), findsWidgets);
    expect(find.textContaining('Nguyen Van A'), findsWidgets);
    expect(find.textContaining('0909123456'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('updatedNameField')),
      'Tran Thi B',
    );
    await tester.tap(find.byKey(const Key('saveBackButton')));
    await tester.pumpAndSettle();

    expect(find.text('Màn hình 2 trả về: Tran Thi B'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Tran Thi B'), findsOneWidget);
  });

  testWidgets('shows canceled result when detail screen is canceled', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byKey(const Key('nameField')), 'Nguyen Van A');
    await tester.tap(find.byKey(const Key('openDetailButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('cancelButton')));
    await tester.pumpAndSettle();

    expect(
      find.text('Người dùng đã hủy, không có dữ liệu trả về'),
      findsOneWidget,
    );
  });

  testWidgets('validates empty name before opening detail screen', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const Key('openDetailButton')));
    await tester.pump();

    expect(find.text('Không được để trống'), findsOneWidget);
    expect(find.text('Chi tiết liên hệ'), findsNothing);
  });
}
