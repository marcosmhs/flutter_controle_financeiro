import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fin/components/util/uid_generator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/controllers/sub_category_controller.dart';
import 'package:fin/models/offer.dart';
import 'package:fin/models/user.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart' as path_provider;
// ignore: depend_on_referenced_packages
import 'package:flutter_image_compress/flutter_image_compress.dart';

class OfferController with ChangeNotifier {
  final User currentUser;
  final List<Offer> _offerList;

  OfferController(this.currentUser, this._offerList);

  List<Offer> get offerList => [..._offerList];

  Future<CustomReturn> save({required Offer offer}) async {
    if (offer.id == '') {
      return _add(offer: offer);
    } else {
      return _update(offer: offer);
    }
  }

  Future<CustomReturn> _add({required Offer offer}) async {
    try {
      final offerId = UidGenerator.firestoreUid;
      final offerData = offer.toMap(
        replaceId: offerId,
        replaceUserId: currentUser.userId,
        replaceCreationDate: DateTime.now(),
        replaceEvaluated: false,
        replaceThumbnailFileName: offer.images![0].name,
        replaceThumbnailUrl: offer.thumbnailUrlGenerator(
          replaceId: offerId,
          replaceThumbnailFileName: 'thumbnail_${offer.imagesThumbnailFileName}',
        ),
      );

      await FirebaseFirestore.instance.collection('offer').doc(offerId).set(offerData);

      offer.id = offerId;
      offer.updateImagesOfferId(forceOfferId: offerId);
      _offerList.add(offer);

      for (var image in offer.images!) {
        await FirebaseFirestore.instance.collection('offerImage').doc(image.id).set(image.toMap());
      }

      _fireStoreImageManager(offer: offer);
      notifyListeners();
      return CustomReturn.sucess;
      //return CustomReturn.error('');
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Future<CustomReturn> _update({required Offer offer}) async {
    int index = _offerList.indexWhere((e) => e.id == offer.id);

    if (index == -1) {
      return CustomReturn(
        returnType: ReturnType.error,
        message: 'Erro interno, oferta não encontrada',
      );
    }

    try {
      await FirebaseFirestore.instance.collection('offer').doc(offer.id).update(
            offer.toMap(),
          );
      await _fireStoreImageManager(offer: offer);
      _offerList[index] = offer;
      notifyListeners();
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Future<CustomReturn> remove({required String offerId}) async {
    if (_offerList.indexWhere((e) => e.id == offerId) == -1) {
      return CustomReturn(returnType: ReturnType.error, message: 'Erro interno, categoria não encontrado');
    }

    try {
      await FirebaseFirestore.instance.collection('offer').doc(offerId).delete();
      _offerList.removeWhere((e) => e.id == offerId);
      await _fireStoreImageManager(deletedAllImagesOfferId: offerId);

      notifyListeners();
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Future<CustomReturn> reloadCurrentUserOfferList({OfferType offerType = OfferType.product, String title = ''}) async {
    try {
      final userOffers = await FirebaseFirestore.instance
          .collection('offer')
          .where('userId', isEqualTo: currentUser.userId)
          .where('offerType', isEqualTo: offerType.toString())
          .get();
      var dataList = userOffers.docs.map((doc) => doc.data()).toList();
      if (title.isNotEmpty) {
        dataList = dataList.where((o) => o['title'].toString().toLowerCase().contains(title.toLowerCase())).toList();
      }
      final subCategoryController = SubCategoryController(currentUser, []);

      await subCategoryController.reloadSubCategoryList();

      _offerList.clear();
      for (var offer in dataList) {
        var subCategory = subCategoryController.subCategoryList.firstWhere((c) => c.id == offer['subCategoryId']);
        var x = Offer.fromMap(
          map: offer,
          setCategory: subCategory.category,
          setSubCategory: subCategory,
        );
        _offerList.add(x);
      }
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Future<CustomReturn> evaluationOffer({required Offer offer}) async {
    if (!currentUser.isAdmin) {
      return CustomReturn(
        returnType: ReturnType.error,
        message: 'Somente administradores podem liberar/bloquear ofertas',
      );
    }

    try {
      await FirebaseFirestore.instance.collection('offer').doc(offer.id).update(
            offer.toMap(
              replaceEvaluated: !offer.evaluated,
              replaceExpirationDate: !offer.evaluated == true ? DateTime.now().add(const Duration(days: 30)) : null,
            ),
          );

      offer.evaluated = !offer.evaluated;
      offer.expirationDate = !offer.evaluated == true ? DateTime.now().add(const Duration(days: 30)) : null;
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn.error(e.toString());
    }
  }

  Future<CustomReturn> _fireStoreImageManager({Offer? offer, String deletedAllImagesOfferId = ''}) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      // used to upload and remove images one by one
      if (offer != null) {
        offer.images?.forEach((image) async {
          // if image is marked to be deleted
          if (image.delete) {
            // should be deleted only if the image have a url to avoid try delete images that wasn`t uploaded
            if (image.url.isNotEmpty) {
              storageRef.child(image.fireStoragePath(image.isMiniature)).delete();
            }
          } else {
            // Create the file metadata
            final metadata = SettableMetadata(contentType: "image/jpeg");
            // if image have a path value it should be send to FireStore
            if (image.path.isNotEmpty) {
              // miniatures
              final smallFile = await _getResizedFileImage(
                path: image.path,
                fileName: image.fireStorageFileName(true),
                size: 200,
              );
              storageRef.child(image.fireStoragePath(true)).putFile(smallFile!, metadata);

              //original images
              final file = File(image.path);
              storageRef.child(image.fireStoragePath(false)).putFile(file, metadata);
            }
          }
        });
      }
      // used to remove all images when a offer is deleted
      if (deletedAllImagesOfferId.isNotEmpty) {
        final list = await storageRef.child("images/you_sell/$deletedAllImagesOfferId").listAll();
        for (var file in list.items) {
          file.delete();
        }
      }
      return CustomReturn.sucess;
    } catch (e) {
      return CustomReturn(returnType: ReturnType.error, message: e.toString());
    }
  }

  Future<File?> _getResizedFileImage({required String path, required int size, required String fileName}) async {
    final tempDir = await path_provider.getTemporaryDirectory();
    return await FlutterImageCompress.compressAndGetFile(
      path,
      '${tempDir.absolute.path}/$fileName',
      quality: 80,
      minWidth: size,
      minHeight: size,
    );
  }

  Future<List<ImageData>> getOfferImageListFromFireStore({required String offerId, bool smallImages = false}) async {
    List<ImageData> imageDataList = [];
    try {
      final userOffers = await FirebaseFirestore.instance
          .collection('offerImage')
          .where('offerId', isEqualTo: offerId)
          .orderBy('position')
          .get();
      var dataList = userOffers.docs.map((doc) => doc.data()).toList();

      for (var image in dataList) {
        var x = ImageData.fromMap(image);
        x.url = x.urlGenerator(smallImages);
        imageDataList.add(x);
      }
      return imageDataList;
    } catch (e) {
      return [];
    }
  }

  Future<List<Offer>> getOffersEvaluationList({required bool evaluated, OfferType offerType = OfferType.product}) async {
    List<Offer> offerLocalList = [];
    try {
      final userOffers = await FirebaseFirestore.instance
          .collection('offer')
          .where('evaluated', isEqualTo: evaluated)
          .where('offerType', isEqualTo: offerType.toString())
          .get();

      final dataList = userOffers.docs.map((doc) => doc.data()).toList();
      var subCategoryController = SubCategoryController(currentUser, []);
      await subCategoryController.reloadSubCategoryList();
      offerLocalList.clear();

      for (var offer in dataList) {
        var subCategory = subCategoryController.subCategoryList.firstWhere((c) => c.id == offer['subCategoryId']);
        var theOffer = Offer.fromMap(
          map: offer,
          setCategory: subCategory.category,
          setSubCategory: subCategory,
        );
        offerLocalList.add(theOffer);
      }
      return offerLocalList;
    } catch (e) {
      return [];
    }
  }
}
