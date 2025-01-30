import '../util/mappable.dart';

class Template implements Mappable {
  final String template;
  final Map<String, dynamic>? variables;

  const Template(this.template, [this.variables]);

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = {'template': template};
    if (variables != null && variables!.isNotEmpty) {
      result['variables'] = variables;
    }
    return result;
  }
}
