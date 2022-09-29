import 'dart:io';
import 'package:fin/components/util/custom_dialog.dart';
import 'package:fin/components/util/custom_message.dart';
import 'package:fin/components/util/custom_scafold.dart';
import 'package:fin/components/util/custom_textFormField.dart';
import 'package:fin/components/util/custom_return.dart';
import 'package:fin/controllers/category_controller.dart';
import 'package:fin/controllers/offer_controller.dart';
import 'package:fin/controllers/sub_category_controller.dart';
import 'package:fin/models/offer.dart';
import 'package:fin/screens/you_sell/category/category_card.dart';
import 'package:fin/screens/you_sell/category/category_selection_list.dart';
// ignore: depend_on_referenced_packages
import 'package:fin/models/item_classification.dart';
import 'package:fin/screens/you_sell/sub_category/sub_category_card.dart';
import 'package:fin/screens/you_sell/sub_category/sub_category_selection_list.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:carousel_slider/carousel_slider.dart';
// ignore: depend_on_referenced_packages
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

enum OfferFormScreenMode { evaluation, crud }

class OffersForm extends StatefulWidget {
  const OffersForm({Key? key}) : super(key: key);
  @override
  State<OffersForm> createState() => _OffersFormState();
}

class _OffersFormState extends State<OffersForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late Offer offer = Offer();
  late bool _categoryError = false;
  late bool _subCategoryError = false;
  late bool _picturesError = false;
  late OfferFormScreenMode _screenMode = OfferFormScreenMode.crud;

  List<bool> _selectedType = [true, false];
  final ImagePickerPlatform _imagePicker = ImagePickerPlatform.instance;

  @override
  void initState() {
    super.initState();
    if (Provider.of<CategoryController>(context, listen: false).categoryList.isEmpty) {
      Provider.of<CategoryController>(context, listen: false).reloadCategoryList();
    }
    if (Provider.of<SubCategoryController>(context, listen: false).subCategoryList.isEmpty) {
      Provider.of<SubCategoryController>(context, listen: false).reloadSubCategoryList();
    }
  }

  void _submit() async {
    if (offer.category.id.isEmpty) {
      setState(() => _categoryError = true);
    }

    if (offer.subCategory.id.isEmpty) {
      setState(() => _subCategoryError = true);
    }

    if (offer.images == null || offer.images!.isEmpty) {
      setState(() => _picturesError = true);
    }

    setState(() => _isLoading = true);

    if (!(_formKey.currentState?.validate() ?? true)) {
      setState(() => _isLoading = false);
    } else {
      // salva os dados
      _formKey.currentState?.save();
      CustomReturn retorno;
      try {
        retorno = await Provider.of<OfferController>(context, listen: false).save(
          offer: offer,
        );
        if (retorno.returnType == ReturnType.sucess) {
          CustomMessage(
            context: context,
            messageText: 'Dados salvos com sucesso',
            messageType: MessageType.sucess,
          );
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        }

        // se houve um erro no login ou no cadastro exibe o erro
        if (retorno.returnType == ReturnType.error) {
          CustomMessage(
            context: context,
            modelType: ModelType.toast,
            messageText: retorno.message,
            messageType: MessageType.error,
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _typeSelection(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('O que deseja ofertar?'),
            ToggleButtons(
              isSelected: _selectedType,
              fillColor: Theme.of(context).primaryColor,
              selectedColor: Colors.black,
              onPressed: (index) {
                setState(() => _selectedType = [index == 0, index == 1]);
                offer.offerType = _selectedType[0] ? OfferType.product : OfferType.service;
              },
              children: [
                SizedBox(
                  width: 110,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.account_box),
                      SizedBox(width: 5),
                      Text('Produto'),
                    ],
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.account_box),
                      SizedBox(width: 5),
                      Text('Serviço'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Card(
          color: offer.evaluated ? Colors.green[200] : Colors.amber[200],
          margin: const EdgeInsets.all(8),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Situação', style: Theme.of(context).textTheme.bodyText1),
                Text(offer.evaluated ? 'Anúncio liberado' : 'Aguardando liberação'),
              ],
            ),
          ),
        ),
        if (offer.evaluated)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Validade', style: Theme.of(context).textTheme.bodyText1),
                  Text(offer.evaluated ? DateFormat('dd/MM/yyyy').format(offer.expirationDate!) : 'Aguardando liberação'),
                ],
              ),
            ),
          )
      ],
    );
  }

  void _categorySelectionClick(BuildContext context) async {
    var category = await showModalBottomSheet<Category>(
      context: context,
      isDismissible: true,
      builder: (context) => const CategorySelectionList(),
    );
    if (category != null) {
      setState(() {
        _categoryError = false;
        _subCategoryError = false;
        offer.categoryId = category.id;
        offer.category = category;
        offer.subCategory = SubCategory();
        offer.subCategoryId = '';
      });
    }
  }

  Widget _categorySelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              _screenMode == OfferFormScreenMode.evaluation ? null : _categorySelectionClick(context);
            },
            child: Container(
              decoration: _categoryError ? BoxDecoration(border: Border.all(color: Theme.of(context).errorColor)) : null,
              child: offer.category.id.isEmpty
                  ? CategoryCard(
                      category: Category(),
                      screenMode: CategoryCardScreenMode.showItem,
                      cropped: true,
                    ).emptyCard(context)
                  : CategoryCard(
                      category: offer.category,
                      screenMode: CategoryCardScreenMode.showItem,
                      cropped: true,
                    ),
            ),
          ),
          if (_categoryError)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 5, 0, 0),
              child: Text(
                'Informe a categoria',
                style: Theme.of(context).textTheme.caption!.merge(TextStyle(color: Theme.of(context).errorColor)),
              ),
            ),
        ],
      ),
    );
  }

  void _subCategorySelectionClick(BuildContext context) async {
    if (offer.category.id.isEmpty) {
      CustomDialog(context: context).informationDialog(message: 'Selecione a categoria antes');
    } else {
      var subCategory = await showModalBottomSheet<SubCategory>(
        context: context,
        isDismissible: true,
        builder: (context) => SubCategorySelectionList(categoryId: offer.categoryId),
      );
      if (subCategory != null) {
        setState(
          () {
            _subCategoryError = false;
            offer.subCategoryId = subCategory.id;
            offer.subCategory = subCategory;
          },
        );
      }
    }
  }

  Widget _subCategorySelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              _screenMode == OfferFormScreenMode.evaluation ? null : _subCategorySelectionClick(context);
            },
            child: Container(
              decoration: _subCategoryError ? BoxDecoration(border: Border.all(color: Theme.of(context).errorColor)) : null,
              child: offer.subCategory.id.isEmpty
                  ? SubCategoryCard(
                      subCategory: SubCategory(),
                      screenMode: SubCategoryCardScreenMode.showItem,
                      cropped: true,
                    ).emptyCard(context)
                  : SubCategoryCard(
                      subCategory: offer.subCategory,
                      screenMode: SubCategoryCardScreenMode.showItem,
                      cropped: true,
                    ),
            ),
          ),
          if (_subCategoryError)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 5, 0, 0),
              child: Text(
                'Informe a subcategoria',
                style: Theme.of(context).textTheme.caption!.merge(TextStyle(color: Theme.of(context).errorColor)),
              ),
            ),
        ],
      ),
    );
  }

  void _addImageFromCamera(BuildContext context) async {
    if (offer.images!.length == 6) {
      await CustomDialog(context: context)
          .informationDialog(message: 'Você já carregou 6 imagens, remova uma antes de carregar uma nova');
    } else {
      final XFile? pickedImage = await _imagePicker.getImageFromSource(
        source: ImageSource.camera,
        options: const ImagePickerOptions(imageQuality: 40),
      );

      if (pickedImage != null) {
        setState(() => offer.addImage(ImageData(
              path: pickedImage.path,
              name: pickedImage.name,
            )));
        _picturesError = false;
      }
    }
  }

  void _addImageList(BuildContext context) async {
    final List<XFile> pickedFileList = await _imagePicker.getMultiImageWithOptions(
      options: const MultiImagePickerOptions(
        imageOptions: ImageOptions(imageQuality: 40),
      ),
    );

    if (pickedFileList.isEmpty) {
      _picturesError = true;
    } else {
      if (pickedFileList.length > 6) {
        await CustomDialog(context: context)
            .informationDialog(message: 'Você selecionou mais de 6 imagens, apenas as 6 primeiras serão mantidas');
        pickedFileList.removeRange(5, pickedFileList.length - 1);
      }

      setState(() {
        offer.images!.clear();
        for (var file in pickedFileList) {
          offer.addImage(ImageData(name: file.name, path: file.path));
        }
      });
    }
  }

  Widget _carrousel({required BuildContext context}) {
    return Container(
      decoration: _picturesError ? BoxDecoration(border: Border.all(color: Theme.of(context).errorColor)) : null,
      padding: const EdgeInsets.only(top: 5),
      child: Card(
        elevation: 2,
        shadowColor: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Imagens',
                style: Theme.of(context).textTheme.labelLarge!.merge(TextStyle(
                      color: Theme.of(context).primaryColor,
                    )),
              ),
              const SizedBox(height: 5),
              offer.images == null || offer.images!.isEmpty
                  // empty message
                  ? Container(
                      height: 130,
                      alignment: Alignment.centerLeft,
                      child: Text(offer.id.isNotEmpty ? 'Carregando imagens' : 'Carregue até 6 imagens'),
                    )
                  // carousel
                  : CarouselSlider(
                      options: CarouselOptions(
                        aspectRatio: 2.0,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: false,
                        viewportFraction: 0.7,
                      ),
                      items: offer.images!
                          .where((image) => !image.delete)
                          .map((item) => Stack(
                                children: [
                                  item.path.isNotEmpty
                                      ? Image.file(File(item.path), fit: BoxFit.cover)
                                      : Image.network(item.url, fit: BoxFit.cover),
                                  if (_screenMode == OfferFormScreenMode.crud)
                                    Positioned(
                                      bottom: 20,
                                      left: 0,
                                      right: 0,
                                      child: FloatingActionButton(
                                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
                                        onPressed: () {
                                          if (offer.id.isEmpty) {
                                            offer.removeImage(item);
                                          } else {
                                            setState(() => item.delete = true);
                                          }
                                        },
                                        child: const Icon(Icons.delete),
                                      ),
                                    ),
                                ],
                              ))
                          .toList(),
                    ),
              // buttoms
              if (_screenMode == OfferFormScreenMode.crud)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // galery
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.photo_library),
                        onPressed: () => _addImageList(context),
                        label: const Text("Imagens da Galeria", textAlign: TextAlign.center),
                      ),
                    ),
                    // camera
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.photo_camera),
                        onPressed: () => _addImageFromCamera(context),
                        label: const Text("Imagem da câmera", textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
              // tips
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Dicas:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('1. Carregue até 6 imagens'),
                    Text('2. A primeira imagem carregada será utilizada como a foto de capa de seu anúncio'),
                    Text('3. Garanta que o local está bem iluminado'),
                    Text('4. Utilize fotos em modo retrado (com o celular deitado)'),
                  ],
                ),
              ),
              if (_picturesError)
                // error message
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 5, 0, 0),
                  child: Text(
                    'Informe até 6 imagens',
                    style: Theme.of(context).textTheme.caption!.merge(TextStyle(color: Theme.of(context).errorColor)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _evaluateOffer(BuildContext context) async {
    var retorno = await Provider.of<OfferController>(context, listen: false).evaluationOffer(
      offer: offer,
    );
    if (retorno.returnType == ReturnType.error) {
      // ignore: use_build_context_synchronously
      CustomMessage.error(context, message: retorno.message);
    } else {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      CustomMessage.sucess(context, message: 'Oferta liberada');
    }
  }

  Widget _buttons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(primary: Theme.of(context).disabledColor),
          onPressed: () => Navigator.of(context).pop(),
          child: const SizedBox(width: 80, child: Text("Cancelar", textAlign: TextAlign.center)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(primary: Theme.of(context).colorScheme.primary),
          onPressed: () {
            if (_screenMode == OfferFormScreenMode.evaluation) {
              _evaluateOffer(context);
            } else {
              _submit();
            }
          },
          child: SizedBox(
              width: 80,
              child: Text(
                _screenMode == OfferFormScreenMode.evaluation ? 'Liberar' : 'Enviar',
                textAlign: TextAlign.center,
              )),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      if (offer.id.isEmpty) {
        var arguments = ModalRoute.of(context)?.settings.arguments as List;
        offer = arguments[0];

        _screenMode = arguments.length == 1 ? OfferFormScreenMode.crud : arguments[1];

        // ModalRoute.of(context)!.settings.arguments as Offer;
        _titleController.text = offer.title;
        _descriptionController.text = offer.description;
        _valueController.text = offer.value.toString();
        Provider.of<OfferController>(context).getOfferImageListFromFireStore(offerId: offer.id).then((value) {
          if (value.isEmpty) {
            CustomMessage.error(context, message: 'Ocorreu um erro ao recuperar as imagens. Tente novamente.');
          }
          setState(() => offer.images = value);
        });
      }
    }

    return CustomScafold(
      title: offer.title == '' ? 'Novo anúncio' : offer.title,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _typeSelection(context),
                _categorySelection(),
                _subCategorySelection(),
                if (offer.id.isNotEmpty) _infoRow(context),
                // title
                CustomTextEdit(
                  context: context,
                  controller: _titleController,
                  onSave: (value) => offer.title = value ?? '',
                  validator: (value) {
                    final finalValue = value ?? '';
                    if (finalValue.trim().isEmpty) return 'O título deve ser informado';
                    return null;
                  },
                  labelText: 'Título',
                  hintText: 'Um resumo do anúncio em poucas palavras',
                ),
                // description
                CustomTextEdit(
                  context: context,
                  controller: _descriptionController,
                  onSave: (value) => offer.description = value ?? '',
                  validator: (value) {
                    final finalValue = value ?? '';
                    if (finalValue.trim().isEmpty) return 'A descrição do anúncio deve ser informada';
                    return null;
                  },
                  labelText: 'Descrição',
                  hintText: 'Descreva detalhes sobre seu anúncio',
                  maxLines: 4,
                ),
                // value
                CustomTextEdit(
                  context: context,
                  controller: _valueController,
                  onSave: (value) => offer.value = double.tryParse(value ?? '') ?? 0,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final finalValue = double.tryParse(value ?? '') ?? 0;
                    if (finalValue == 0) return 'Informe o valor do anúncio';
                    return null;
                  },
                  labelText: 'Valor',
                  hintText: 'Valor',
                ),
                _carrousel(context: context),
                // about evaluation time and expiration date
                Card(
                  elevation: 2,
                  shadowColor: Theme.of(context).primaryColor,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                    child: Text(
                      'Seu anúncio será avaliado e liberado pelo time de acompanhamento em até 48 horas. Após a liberação ele ficará ativo por 30 dias contando a partir do momento em que o anúncio foi liberado.',
                    ),
                  ),
                ),
                // butons
                _isLoading ? const CircularProgressIndicator() : _buttons(context)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
