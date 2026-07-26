import 'package:sqflite/sqflite.dart';

abstract interface class AppDatabase {
  Future<DatabaseExecutor> get executor;
  Future<void> reset();
}
