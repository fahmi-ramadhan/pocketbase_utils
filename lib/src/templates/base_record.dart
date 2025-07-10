import 'package:code_builder/code_builder.dart' as code_builder;
import 'package:dart_style/dart_style.dart';
import 'package:pocketbase_utils/src/schema/field.dart';
import 'package:pocketbase_utils/src/templates/do_not_modify_by_hand.dart';

String baseRecordClassGenerator(int lineLength) {
  const className = 'BaseRecord';

  final classCode = code_builder.Class(
    (c) => c
      ..name = className
      ..abstract = true
      ..modifier = code_builder.ClassModifier.base
      ..extend = code_builder.refer('Equatable', 'package:equatable/equatable.dart')
      ..fields.addAll([
        for (final field in baseFields) field.toCodeBuilder(className),
      ])
      ..constructors.addAll([
        code_builder.Constructor((d) => d
          ..optionalParameters.addAll([
            for (final field in baseFields)
              code_builder.Parameter(
                (p) => p
                  ..toThis = true
                  ..name = field.nameInCamelCase
                  ..named = true
                  ..required = field.isNonNullable,
              ),
          ])),
      ])
      ..methods.addAll([
        code_builder.Method((m) => m
          ..annotations.add(code_builder.refer('override'))
          ..returns = code_builder.refer('List<Object?>')
          ..type = code_builder.MethodType.getter
          ..name = 'props'
          ..lambda = true
          ..body = code_builder.literalList([
            for (final field in baseFields) code_builder.refer(field.nameInCamelCase),
          ]).code),
      ]),
  );

  final libraryCode = code_builder.Library(
    (l) => l
      ..body.add(classCode)
      ..ignoreForFile.add('unused_import')
      ..directives.addAll([
        code_builder.Directive.import('date_time_json_methods.dart'),
        code_builder.Directive.import('package:json_annotation/json_annotation.dart'),
      ])
      ..generatedByComment = doNotModifyByHandTemplate,
  );

  final emitter = code_builder.DartEmitter.scoped(
    useNullSafetySyntax: true,
    orderDirectives: true,
  );

  return DartFormatter(
    languageVersion: DartFormatter.latestShortStyleLanguageVersion,
    pageWidth: lineLength,
  ).format('${libraryCode.accept(emitter)}');
}
