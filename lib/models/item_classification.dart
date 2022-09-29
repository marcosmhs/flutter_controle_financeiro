class Category {
  String id;
  String name;
  bool active;
  int iconCode;

  Category({
    this.id = '',
    this.name = '',
    this.active = true,
    this.iconCode = 0,
  });
  Map<String, Object> get toMap {
    return {
      'id': id,
      'name': name,
      'iconCode': iconCode,
      'active': active,
    };
  }
}

class SubCategory {
  String id;
  String name;
  String categoryId;
  bool active;
  int iconCode;
  Category? category;

  SubCategory({
    this.id = '',
    this.name = '',
    this.categoryId = '',
    this.active = true,
    this.iconCode = 0,
    this.category,
  });

  Map<String, Object> toMap({bool onlyBasicTypes = true}) {
    var result = {
      'id': id,
      'name': name,
      'iconCode': iconCode,
      'categoryId': categoryId,
      'active': active,
    };
    if (!onlyBasicTypes) {
      result['category'] = category == null ? '' : category!.toMap.toString();
    }

    return result;
  }
}
