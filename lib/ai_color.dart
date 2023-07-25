/// This is a package that will help users quickly find the necessary colors for their projects using only a text description
library ai_color;

/// Necessary packages for the library
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AIColor class that contain DataBase, apiKey for OpenAI, and functions getColor and updateColor by a request String
class AIColor {

  /// ColorDatabase contains the results of sent requests so as not to make the same requests when restarting
  ColorDatabase colorDB = ColorDatabase();

  /// apiKey for the OpenAI
  String apiKey = "";

  /// Constructor of the AIColor class
  AIColor(final String key) {
    apiKey = key;
  }

  /// updateColor functions that return Color by a requestColor String
  ///
  /// It makes a request directly through the OpenAI Api and returns a value of a color type: Color
  /// Requests to the OpenAI are made until the correct result is returned
  /// Obtained result updated in the colorDataBase
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

  /// getColor functions that return Color by a requestColor String
  ///
  /// If there has already been exactly the same request, it returns the result of the response from the database
  ///
  /// In another case it makes a request directly through the OpenAI Api and returns a value of a color type: Color
  /// Requests to the OpenAI are made until the correct result is returned
  /// Obtained result added to the colorDataBase
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

/// ColorDatabase store answers of the requests to the OpenAI api
class ColorDatabase {
  static const String _colorKeyPrefix = 'color_';
  SharedPreferences? _preferences;

  Future<void> _initPreferences() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  /// Inserting a new value by {request string and obtained value}
  Future<void> insert(String key, Color value) async {
    await _initPreferences();
    _preferences!.setInt(_getColorKey(key), value.value);
  }

  /// Updating a  value by {request string and obtained value}
  Future<void> update(String key, Color value) async {
    await _initPreferences();
    if (_preferences!.containsKey(_getColorKey(key))) {
      _preferences!.setInt(_getColorKey(key), value.value);
    }
    else {
      insert(key, value);
    }
  }

  /// Сhecks whether the following key (request) is in the database
  Future<bool> containsKey(String key) async {
    await _initPreferences();
    return _preferences!.containsKey(_getColorKey(key));
  }

  /// Gets color by key (request)
  Color? getColor(String key) {
    final int? colorValue = _preferences!.getInt(_getColorKey(key));
    return colorValue != null ? Color(colorValue) : null;
  }

  /// Deletes a key by value
  Future<void> remove(String key) async {
    await _initPreferences();
    _preferences!.remove(_getColorKey(key));
  }

  /// Full clear database
  Future<void> clear() async {
    await _initPreferences();
    _preferences!.clear();
  }

  String _getColorKey(String key) => '$_colorKeyPrefix$key';
}
