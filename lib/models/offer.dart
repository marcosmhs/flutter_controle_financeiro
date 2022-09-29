import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fin/components/util/uid_generator.dart';
import 'package:fin/models/item_classification.dart';

enum OfferType { product, service }

const String firebase = 'https://firebasestorage.googleapis.com/v0/b';
const String project = 'redfive-fin.appspot.com/o';

class ImageData {
  // general variables, saved on firestore
  late String id;
  late String offerId;
  late int position;
  late String name;
  // local variables, used only on the app
  late String path;
  late String url;
  late bool delete;
  late bool isMiniature;

  ImageData({
    this.path = '',
    this.name = '',
    this.url = '',
    this.delete = false,
    this.position = 0,
    this.isMiniature = false,
    this.offerId = '',
    this.id = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'offerId': offerId,
      'position': position,
      'name': name,
    };
  }

  static ImageData fromMap(Map<String, dynamic> map) {
    return ImageData(
      id: map['id'],
      offerId: map['offerId'],
      position: map['position'],
      name: map['name'],
    );
  }

  String fireStoragePath(bool miniature) {
    return miniature
        ? 'images/you_sell/$offerId/small_images/${fireStorageFileName(miniature)}'
        : 'images/you_sell/$offerId/$name';
  }

  String fireStorageFileName(bool miniature) {
    return !miniature ? name : '${position == 1 ? 'thumbnail' : 'miniature'}_$name';
  }

  String urlGenerator(bool miniature) {
    String mainPath = 'images%2Fyou_sell%2F$offerId';
    mainPath = '$mainPath${miniature ? '/small_images' : ''}';
    return '$firebase/$project/$mainPath%2F${fireStorageFileName(miniature)}?alt=media';
  }
}

class Offer {
  late String id;
  late String userId;
  late String title;
  late String description;
  late double value;
  late String categoryId;
  late String subCategoryId;
  late DateTime? creationDate;
  late DateTime? expirationDate;
  late bool evaluated;
  late Category category;
  late SubCategory subCategory;
  late String thumbnailFileName;
  late String thumbnailUrl;
  late OfferType offerType;
  List<ImageData>? images;

  Offer({
    this.id = '',
    this.userId = '',
    this.title = '',
    this.description = '',
    this.value = 0,
    this.categoryId = '',
    this.subCategoryId = '',
    this.creationDate,
    this.expirationDate,
    this.evaluated = false,
    this.thumbnailFileName = '',
    this.thumbnailUrl = '',
    this.offerType = OfferType.product,
    Category? category,
    SubCategory? subCategory,
    List<ImageData>? images,
  }) {
    this.category = category ?? Category();
    this.subCategory = subCategory ?? SubCategory();
    this.images = images ?? [];
  }

  bool get active {
    if (expirationDate == null) return false;
    return expirationDate!.isBefore(DateTime.now()) && evaluated;
  }

  String thumbnailUrlGenerator({String? replaceId, String? replaceThumbnailFileName}) {
    const String firebase = 'https://firebasestorage.googleapis.com/v0/b';
    const String project = 'redfive-fin.appspot.com/o';
    const String mainPath = 'images%2Fyou_sell';
    return '$firebase/$project/$mainPath%2F${replaceId ?? id}%2Fsmall_images%2F${replaceThumbnailFileName ?? thumbnailFileName}?alt=media';
  }

  String get imagesThumbnailFileName => images == null ? '' : images!.firstWhere((i) => i.position == 1).name;

  void addImage(ImageData imageData) {
    imageData.id = UidGenerator.firestoreUid;
    imageData.position = images!.length + 1;
    images!.add(imageData);
  }

  void removeImage(ImageData imageData) {
    images!.remove(imageData);
    images!.sort((a, b) => a.position);
    for (var x = 1; x <= images!.length - 1; x++) {
      images![x].position = x;
    }
  }

  void updateImagesOfferId({String? forceOfferId}) {
    for (var x = 0; x <= images!.length - 1; x++) {
      images![x].offerId = forceOfferId ?? id;
    }
  }

  Map<String, dynamic> toMap({
    String? replaceId,
    String? replaceUserId,
    String? replaceTitle,
    String? replaceDescription,
    double? replaceValue,
    String? replaceCategoryId,
    String? replaceSubCategoryId,
    DateTime? replaceCreationDate,
    DateTime? replaceExpirationDate,
    bool? replaceEvaluated,
    String? replaceThumbnailFileName,
    String? replaceThumbnailUrl,
    OfferType? replaceOfferType,
  }) {
    return {
      'id': replaceId ?? id,
      'userId': replaceUserId ?? userId,
      'title': replaceTitle ?? title,
      'description': replaceDescription ?? description,
      'value': replaceValue ?? value,
      'categoryId': replaceCategoryId ?? categoryId,
      'subCategoryId': replaceSubCategoryId ?? subCategoryId,
      'creationDate': replaceCreationDate ?? creationDate,
      'expirationDate': replaceExpirationDate ?? expirationDate,
      'evaluated': replaceEvaluated ?? false,
      'thumbnailFileName': replaceThumbnailFileName ?? thumbnailFileName,
      'thumbnailUrl': replaceThumbnailUrl ?? thumbnailUrl,
      'offerType': replaceOfferType?.toString() ?? offerType.toString(),
    };
  }

  static Offer fromMap({required Map<String, dynamic> map, Category? setCategory, SubCategory? setSubCategory}) {
    return Offer(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      value: map['value'] ?? 0,
      categoryId: map['categoryId'],
      subCategoryId: map['subCategoryId'],
      evaluated: map['evaluated'],
      creationDate: (map['creationDate'] as Timestamp).toDate(),
      expirationDate: map['expirationDate'] == null || map['expirationDate'].toString().isEmpty
          ? null
          : (map['expirationDate'] as Timestamp).toDate(),
      category: setCategory,
      subCategory: setSubCategory,
      thumbnailFileName: map['thumbnailFileName'],
      thumbnailUrl: map['thumbnailUrl'],
      offerType: map['offerType'] == OfferType.product.toString() ? OfferType.product : OfferType.service,
    );
  }
}
