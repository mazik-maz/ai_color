library ai_color;

import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AIColor {
  ColorDatabase colorDB = ColorDatabase();
  String apiKey = "";

  AIColor(final String key) {
    apiKey = key;
  }

  Future<Color?> updateColor(final String requestColor) async {
    OpenAI.apiKey = apiKey;
    try {
      OpenAIChatCompletionModel completion = await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: """send a color of "$requestColor"
          prompt: hexadecimal format, only JSON, no other words, without '#'""",
            role: OpenAIChatMessageRole.user,
          ),
        ],
      );
      log(completion.choices.first.message.content);
      String ans = jsonDecode(completion.choices.first.message.content)["color"];
      ans = ans.replaceAll("0x", "");
      colorDB.insert(requestColor, Color(int.parse("0xFF$ans")));
      return Color(int.parse("0xFF$ans"));
    } catch (e) {
      log(e.toString());
      return updateColor(requestColor);
    }
  }

  Future<Color?> getColor(final String requestColor) async {
    if(await colorDB.containsKey(requestColor)){
      return colorDB.getColor(requestColor);
    }
    OpenAI.apiKey = apiKey;
    try {
      OpenAIChatCompletionModel completion = await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: """send a color of "$requestColor"
          prompt: hexadecimal format, only JSON, no other words, without '#'""",
            role: OpenAIChatMessageRole.user,
          ),
        ],
      );
      log(completion.choices.first.message.content);
      String ans = jsonDecode(completion.choices.first.message.content)["color"];
      ans = ans.replaceAll("0x", "");
      colorDB.insert(requestColor, Color(int.parse("0xFF$ans")));
      return Color(int.parse("0xFF$ans"));
    } catch (e) {
      log(e.toString());
      return getColor(requestColor);
    }
  }
}

class ColorDatabase {
  static const String _colorKeyPrefix = 'color_';
  SharedPreferences? _preferences;

  Future<void> _initPreferences() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  // Вставка нового значения String: Color
  Future<void> insert(String key, Color value) async {
    await _initPreferences();
    _preferences!.setInt(_getColorKey(key), value.value);
  }

  // Обновление значения Color для существующего String
  Future<void> update(String key, Color value) async {
    await _initPreferences();
    if (_preferences!.containsKey(_getColorKey(key))) {
      _preferences!.setInt(_getColorKey(key), value.value);
    }
    else {
      insert(key, value);
    }
  }

  // Проверка существования элемента с определенным String
  Future<bool> containsKey(String key) async {
    await _initPreferences();
    return _preferences!.containsKey(_getColorKey(key));
  }

  // Получение цвета по ключу String
  Color? getColor(String key) {
    final int? colorValue = _preferences!.getInt(_getColorKey(key));
    return colorValue != null ? Color(colorValue) : null;
  }

  // Удаление элемента по ключу String
  Future<void> remove(String key) async {
    await _initPreferences();
    _preferences!.remove(_getColorKey(key));
  }

  // Очистка базы данных
  Future<void> clear() async {
    await _initPreferences();
    _preferences!.clear();
  }

  String _getColorKey(String key) => '$_colorKeyPrefix$key';
}
