// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pawsome/configuration/configuration.dart';
import 'package:pawsome/model/location.dart';
import 'package:pawsome/resources/color_manager.dart';
import 'package:pawsome/resources/strings_manager.dart';
import 'package:pawsome/utils/utils.dart';
import 'package:pawsome/viewmodel/user_viewmodel.dart';
import 'package:provider/provider.dart';
import '../model/firebase_methods/firestore_methods.dart';
import '../model/user.dart';
import 'package:pawsome/widget/pet_textfield.dart';
import 'package:currency_picker/currency_picker.dart';

enum Gender { Male, Female }

// Map<Gender, String> _genderTypes = <Gender, String>{
//   Gender.male: 'Male',
//   Gender.female: 'Female',
// };

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  AddPetScreenState createState() => AddPetScreenState();
}

class AddPetScreenState extends State<AddPetScreen>
    with AutomaticKeepAliveClientMixin<AddPetScreen> {
  bool _isHybrid = false;
  bool _isEnabled = false;
  bool _isLoading = false;
  String _currency = '-';
  Uint8List? _image;
  late Map<String, List<List<String>>> animalMap;
  List<String> _selectedSpeciesList = [
    AppStrings.unknown.tr(),
    AppStrings.africanGrayParrot.tr(),
    AppStrings.amazonParrot.tr(),
    AppStrings.blueHeadedParrot.tr(),
    AppStrings.bronzeWingedParrot.tr(),
    AppStrings.budgerigarBudgieParakeet.tr(),
    AppStrings.canary.tr(),
    AppStrings.cockatiel.tr(),
    AppStrings.cockatoo.tr(),
    AppStrings.dovePigeon.tr(),
    AppStrings.duskyPionus.tr(),
    AppStrings.eclectusParrot.tr(),
    AppStrings.finch.tr(),
    AppStrings.greenCheekedParakeet.tr(),
    AppStrings.hyacinthMacaw.tr(),
    AppStrings.loveBird.tr(),
    AppStrings.macaw.tr(),
    AppStrings.monkParakeet.tr(),
    AppStrings.redBilledPionus.tr(),
    AppStrings.scalyHeadedPionus.tr(),
    AppStrings.senegalParrot.tr(),
    AppStrings.sunParakeet.tr(),
    AppStrings.roseRingedParakeet.tr(),
    AppStrings.whiteCrownedPionus.tr(),
    AppStrings.zebraFinch.tr(),
  ];
  Gender _selectedGender = Gender.Male;
  String _selectedPetClass = AppStrings.bird;

  final _firstSpeciesKey = GlobalKey<DropdownSearchState<String>>();
  final _secondSpeciesKey = GlobalKey<DropdownSearchState<String>>();

  final ScrollController _scrollController = ScrollController();

  Color nameColor = ColorManager.primary;
  Color ageColor = ColorManager.primary;
  Color priceColor = ColorManager.primary;
  Color descriptionColor = ColorManager.primary;

  final _petNameFocusNode = FocusNode();
  final _petAgeFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();

  final TextEditingController _petNameTextEditingController =
      TextEditingController();
  final TextEditingController _petAgeTextEditingController =
      TextEditingController();
  final TextEditingController _descriptionTextEditingController =
      TextEditingController();
  final TextEditingController _priceTextEditingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _petNameFocusNode.addListener(() => setState(() {}));
    _petAgeFocusNode.addListener(() => setState(() {}));
    _descriptionFocusNode.addListener(() => setState(() {}));
    _priceFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _petNameTextEditingController.dispose();
    _petAgeTextEditingController.dispose();
    _descriptionTextEditingController.dispose();
    _priceTextEditingController.dispose();
    _petNameFocusNode.dispose();
    _petAgeFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void petClassSelected(String? value) {
    _firstSpeciesKey.currentState!.changeSelectedItem(AppStrings.unknown.tr());
    _secondSpeciesKey.currentState!.changeSelectedItem(AppStrings.unknown.tr());
    if (value != null) {
      final int index = animalClass.indexWhere((element) => element == value);
      _selectedPetClass = animalValueClass[index];
      _selectedSpeciesList = animalMap[value]![0];
      // setState(() {
      // _selectedPetClass = value;
      // _selectedPetClass = animalValueClass[index];
      // _selectedSpeciesList = animalMap[value]![0];
      // });
    }
  }

  void registerPet(BuildContext context, String uid, String ownerName,
      String ownerUid, String ownerEmail, String ownerPhotoUrl) async {
    setState(() => _isLoading = true);
    if (_image == null) {
      showDialog(
          context: context,
          builder: (context) {
            _isLoading = false;
            if (!Platform.isIOS) {
              return AlertDialog(
                title: const Text(AppStrings.errorRegister).tr(),
                content: const Text(AppStrings.selectPetImage).tr(),
              );
            } else {
              return CupertinoAlertDialog(
                title: const Text(AppStrings.errorRegister).tr(),
                content: const Text(AppStrings.selectPetImage).tr(),
              );
            }
          });
      return;
    } else if (_petNameTextEditingController.text.trim().isEmpty) {
      _scrollToField(_petNameFocusNode, 0);
    } else if (_petAgeTextEditingController.text.trim().isEmpty) {
      _scrollToField(_petAgeFocusNode, 80);
    } else if (_currency == '-') {
      _popCurrencyPicker();
    } else if (_priceTextEditingController.text.trim().isEmpty) {
      _scrollToField(_priceFocusNode, null);
    } else if (_descriptionTextEditingController.text.trim().isEmpty) {
      _scrollToField(_descriptionFocusNode, null);
    } else {
      try {
        if (await checkConnectivity()) {
          Position currentLocation = await LocationModel.determinePosition();
          await FirestoreMethods.uploadRegisteredPet(
                  _image!,
                  uid,
                  _selectedGender.name,
                  _petNameTextEditingController.text.trim(),
                  _petAgeTextEditingController.text,
                  _selectedPetClass,
                  _getPetSpecies(),
                  _getPetPrice(),
                  _descriptionTextEditingController.text.trim(),
                  ownerName,
                  ownerUid,
                  ownerEmail,
                  currentLocation,
                  ownerPhotoUrl)
              .then((value) {
            if (value == 'success') {
              Navigator.pop(context, AppStrings.petRegisteredSuccessfully.tr());
            } else {
              showSnackBar(context, value, defaultColor: false);
            }
          });
        } else {
          showSnackBar(context, AppStrings.noConnection.tr(),
              defaultColor: false);
        }
      } catch (e) {
        showSnackBar(context, e.toString(), defaultColor: false);
      }
    }
    setState(() => _isLoading = false);
  }

  String _getPetSpecies() {
    if (_isHybrid == false ||
        _secondSpeciesKey.currentState!.getSelectedItem! ==
            AppStrings.unknown.tr()) {
      final int index = _selectedSpeciesList.indexWhere((element) =>
          element == _firstSpeciesKey.currentState!.getSelectedItem!);
      final String firstSpeciesValue =
          animalMap[_selectedPetClass.tr()]![1][index];
      return firstSpeciesValue;
    } else if (_firstSpeciesKey.currentState!.getSelectedItem! ==
        _secondSpeciesKey.currentState!.getSelectedItem!) {
      final int index = _selectedSpeciesList.indexWhere((element) =>
          element == _firstSpeciesKey.currentState!.getSelectedItem!);
      final String firstSpeciesValue =
          animalMap[_selectedPetClass.tr()]![1][index];
      return firstSpeciesValue;
    } else {
      final int firstIndex = _selectedSpeciesList.indexWhere((element) =>
          element == _firstSpeciesKey.currentState!.getSelectedItem!);
      final int secondIndex = _selectedSpeciesList.indexWhere((element) =>
          element == _secondSpeciesKey.currentState!.getSelectedItem!);
      final String firstSpeciesValue =
          animalMap[_selectedPetClass.tr()]![1][firstIndex];
      final String secondSpeciesValue =
          animalMap[_selectedPetClass.tr()]![1][secondIndex];

      return '$firstSpeciesValue & $secondSpeciesValue';
    }
  }

  String _getPetPrice() {
    return '$_currency ${_priceTextEditingController.text}';
  }

  void _popCurrencyPicker() {
    showCurrencyPicker(
        context: context,
        onSelect: (Currency currency) {
          setState(() {
            _currency = currency.code;
          });
        });
  }

  void _scrollToField(FocusNode node, double? location) {
    setState(() {
      _scrollController
          .animateTo(location ?? _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn)
          .then((_) {
        node.requestFocus();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserViewModel>(context).getUser;

    animalClass = [
      AppStrings.bird.tr(),
      AppStrings.cat.tr(),
      AppStrings.dog.tr(),
      AppStrings.ferret.tr(),
      AppStrings.fish.tr(),
      AppStrings.guineaPig.tr(),
      AppStrings.horse.tr(),
      AppStrings.iguana.tr(),
      AppStrings.mouseRat.tr(),
      AppStrings.otter.tr(),
      AppStrings.rabbit.tr(),
      AppStrings.tortoise.tr(),
    ];

    List<String> birdSpecies = [
      AppStrings.unknown.tr(),
      AppStrings.africanGrayParrot.tr(),
      AppStrings.amazonParrot.tr(),
      AppStrings.blueHeadedParrot.tr(),
      AppStrings.bronzeWingedParrot.tr(),
      AppStrings.budgerigarBudgieParakeet.tr(),
      AppStrings.canary.tr(),
      AppStrings.cockatiel.tr(),
      AppStrings.cockatoo.tr(),
      AppStrings.dovePigeon.tr(),
      AppStrings.duskyPionus.tr(),
      AppStrings.eclectusParrot.tr(),
      AppStrings.finch.tr(),
      AppStrings.greenCheekedParakeet.tr(),
      AppStrings.hyacinthMacaw.tr(),
      AppStrings.loveBird.tr(),
      AppStrings.macaw.tr(),
      AppStrings.monkParakeet.tr(),
      AppStrings.redBilledPionus.tr(),
      AppStrings.scalyHeadedPionus.tr(),
      AppStrings.senegalParrot.tr(),
      AppStrings.sunParakeet.tr(),
      AppStrings.roseRingedParakeet.tr(),
      AppStrings.whiteCrownedPionus.tr(),
      AppStrings.zebraFinch.tr(),
    ];

    List<String> catSpecies = [
      AppStrings.unknown.tr(),
      AppStrings.abyssinian.tr(),
      AppStrings.americanBobtail.tr(),
      AppStrings.americanCurl.tr(),
      AppStrings.americanShorthair.tr(),
      AppStrings.americanWirehair.tr(),
      AppStrings.bengalCat.tr(),
      AppStrings.birman.tr(),
      AppStrings.balineseCat.tr(),
      AppStrings.bombayCat.tr(),
      AppStrings.britishLonghair.tr(),
      AppStrings.britishShorthair.tr(),
      AppStrings.burmeseCat.tr(),
      AppStrings.burmilla.tr(),
      AppStrings.caracal.tr(),
      AppStrings.chartreux.tr(),
      AppStrings.cornishRex.tr(),
      AppStrings.cymric.tr(),
      AppStrings.donskoy.tr(),
      AppStrings.europeanShorthair.tr(),
      AppStrings.exoticShorthair.tr(),
      AppStrings.havanaBrown.tr(),
      AppStrings.himalayanCat.tr(),
      AppStrings.korat.tr(),
      AppStrings.laperm.tr(),
      AppStrings.lykoi.tr(),
      AppStrings.maineCoon.tr(),
      AppStrings.manxCat.tr(),
      AppStrings.munchkinCat.tr(),
      AppStrings.nebelung.tr(),
      AppStrings.norwegianForestCat.tr(),
      AppStrings.ocicat.tr(),
      AppStrings.orientalLonghair.tr(),
      AppStrings.orientalShorthair.tr(),
      AppStrings.persianCat.tr(),
      AppStrings.peterbald.tr(),
      AppStrings.ragamuffin.tr(),
      AppStrings.ragdoll.tr(),
      AppStrings.russianBlue.tr(),
      AppStrings.savannahCat.tr(),
      AppStrings.scottishFold.tr(),
      AppStrings.selkirkRex.tr(),
      AppStrings.siameseCat.tr(),
      AppStrings.siberianCat.tr(),
      AppStrings.singapuraCat.tr(),
      AppStrings.somaliCat.tr(),
      AppStrings.sphynxCat.tr(),
      AppStrings.thaiCat.tr(),
      AppStrings.tonkineseCat.tr(),
      AppStrings.toyger.tr(),
      AppStrings.turkishAngora.tr(),
      AppStrings.vanCat.tr(),
    ];

    List<String> dogSpecies = [
      AppStrings.unknown.tr(),
      AppStrings.affenpinscher.tr(),
      AppStrings.afghanHound.tr(),
      AppStrings.airedaleTerrier.tr(),
      AppStrings.alaskanMalamute.tr(),
      AppStrings.americanBulldog.tr(),
      AppStrings.americanEskimoDog.tr(),
      AppStrings.americanStaffordshireTerrier.tr(),
      AppStrings.australianCattleDog.tr(),
      AppStrings.australianShepherd.tr(),
      AppStrings.basenji.tr(),
      AppStrings.bassetHound.tr(),
      AppStrings.beagle.tr(),
      AppStrings.beardedCollie.tr(),
      AppStrings.belgianShepherd.tr(),
      AppStrings.berneseMountainDog.tr(),
      AppStrings.bichonFrise.tr(),
      AppStrings.borderCollie.tr(),
      AppStrings.borderTerrier.tr(),
      AppStrings.bostonTerrier.tr(),
      AppStrings.boxer.tr(),
      AppStrings.brittany.tr(),
      AppStrings.brusselsGriffon.tr(),
      AppStrings.bulldog.tr(),
      AppStrings.bullTerrier.tr(),
      AppStrings.cairnTerrier.tr(),
      AppStrings.cavalierKingCharlesSpaniel.tr(),
      AppStrings.chihuahua.tr(),
      AppStrings.chowChow.tr(),
      AppStrings.dachshund.tr(),
      AppStrings.dalmation.tr(),
      AppStrings.dobermann.tr(),
      AppStrings.englishCockerSpaniel.tr(),
      AppStrings.frenchBulldog.tr(),
      AppStrings.germanShepherd.tr(),
      AppStrings.greatDane.tr(),
      AppStrings.goldenRetriever.tr(),
      AppStrings.irishSetter.tr(),
      AppStrings.labradorRetriever.tr(),
      AppStrings.malteseDog.tr(),
      AppStrings.newfoundlandDog.tr(),
      AppStrings.papillon.tr(),
      AppStrings.pembrokeWelshCorgi.tr(),
      AppStrings.pomeranian.tr(),
      AppStrings.poodle.tr(),
      AppStrings.pug.tr(),
      AppStrings.rottweiler.tr(),
      AppStrings.shetlandSheepdog.tr(),
      AppStrings.shihTzu.tr(),
      AppStrings.siberianHusky.tr(),
      AppStrings.softcoatedWheatenTerrier.tr(),
      AppStrings.yorkshireTerrier.tr(),
    ];

    List<String> ferretSpecies = [
      AppStrings.unknown.tr(),
      AppStrings.albinoFerret.tr(),
      AppStrings.blazeFerret.tr(),
      AppStrings.champagneFerret.tr(),
      AppStrings.chocolateFerret.tr(),
      AppStrings.cinnamonFerret.tr(),
      AppStrings.dalmatianFerret.tr(),
      AppStrings.pandaFerret.tr(),
      AppStrings.siameseFerret.tr(),
      AppStrings.silverFerret.tr(),
    ];

    List<String> fishSpecies = [
      AppStrings.unknown.tr(),
      AppStrings.africanCichlid.tr(),
      AppStrings.angelfish.tr(),
      AppStrings.asianStoneCatfish.tr(),
      AppStrings.bichir.tr(),
      AppStrings.bloodfinTetra.tr(),
      AppStrings.bloodParrotCichlid.tr(),
      AppStrings.cardinalTetra.tr(),
      AppStrings.cherryBarb.tr(),
      AppStrings.cherryShrimp.tr(),
      AppStrings.clownLoach.tr(),
      AppStrings.convictCichlid.tr(),
      AppStrings.danioMargaritatus.tr(),
      AppStrings.diamondTetra.tr(),
      AppStrings.dwarfGourami.tr(),
      AppStrings.firemouthCichlid.tr(),
      AppStrings.glassCatfish.tr(),
      AppStrings.goldBarb.tr(),
      AppStrings.goldfish.tr(),
      AppStrings.greenTexasCichlid.tr(),
      AppStrings.guppy.tr(),
      AppStrings.harlequinRasboras.tr(),
      AppStrings.jackDempsey.tr(),
      AppStrings.killifish.tr(),
      AppStrings.kuhliLoach.tr(),
      AppStrings.marbledHatchetfish.tr(),
      AppStrings.mollies.tr(),
      AppStrings.neonTetra.tr(),
      AppStrings.odessaBarb.tr(),
      AppStrings.oscarCichlid.tr(),
      AppStrings.otocinclus.tr(),
      AppStrings.pearlGourami.tr(),
      AppStrings.pictusCatfish.tr(),
      AppStrings.platy.tr(),
      AppStrings.rainbowfish.tr(),
      AppStrings.rainbowShark.tr(),
      AppStrings.ramCichlid.tr(),
      AppStrings.raphaelCatfish.tr(),
      AppStrings.redeyeTetra.tr(),
      AppStrings.rosyBarb.tr(),
      AppStrings.siameseFightingFish.tr(),
      AppStrings.swordTail.tr(),
      AppStrings.tigerBarb.tr(),
      AppStrings.upsideDownCatfish.tr(),
      AppStrings.whiteCloudMountainMinnow.tr(),
      AppStrings.zebrafish.tr(),
    ];

    List<String> horseSpecies = [
      AppStrings.unknown.tr(),
      AppStrings.akhalTeke.tr(),
      AppStrings.americanPaintHorse.tr(),
      AppStrings.americanQuarterHorse.tr(),
      AppStrings.americanSaddlebred.tr(),
      AppStrings.andalusianHorse.tr(),
      AppStrings.appaloosa.tr(),
      AppStrings.arabianHorse.tr(),
      AppStrings.ardennais.tr(),
      AppStrings.belgianHorse.tr(),
      AppStrings.belgianWarmblood.tr(),
      AppStrings.blackForestHorse.tr(),
      AppStrings.bretonHorse.tr(),
      AppStrings.clydesdaleHorse.tr(),
      AppStrings.criolloHorse.tr(),
      AppStrings.curlyHorse.tr(),
      AppStrings.dutchWarmblood.tr(),
      AppStrings.falabella.tr(),
      AppStrings.fellPony.tr(),
      AppStrings.fjordHorse.tr(),
      AppStrings.friesianHorse.tr(),
      AppStrings.gypsyHorse.tr(),
      AppStrings.haflinger.tr(),
      AppStrings.hanoverianHorse.tr(),
      AppStrings.holsteiner.tr(),
      AppStrings.huculPony.tr(),
      AppStrings.icelandicHorse.tr(),
      AppStrings.irishSportHorse.tr(),
      AppStrings.knabstrupper.tr(),
      AppStrings.konik.tr(),
      AppStrings.lipizzan.tr(),
      AppStrings.lusitano.tr(),
      AppStrings.mangalargaMarchador.tr(),
      AppStrings.marwariHorse.tr(),
      AppStrings.missouriFoxTrotter.tr(),
      AppStrings.mongolianHorse.tr(),
      AppStrings.morganHorse.tr(),
      AppStrings.mustang.tr(),
      AppStrings.noriker.tr(),
      AppStrings.pasoFino.tr(),
      AppStrings.percheron.tr(),
      AppStrings.peruvianPaso.tr(),
      AppStrings.shetlandPony.tr(),
      AppStrings.shireHorse.tr(),
      AppStrings.silesianHorse.tr(),
      AppStrings.standardbred.tr(),
      AppStrings.tennesseeWalkingHorse.tr(),
      AppStrings.trakehner.tr(),
    ];

    List<String> guineaPigSpecies = [
      AppStrings.unknown.tr(),
      AppStrings.abyssinianGuineaPig.tr(),
      AppStrings.americanGuineaPig.tr(),
      AppStrings.peruvianGuineaPig.tr(),
      AppStrings.rexGuineaPig.tr(),
      AppStrings.sheltieSilkieGuineaPig.tr(),
      AppStrings.skinnyGuineaPig.tr(),
      AppStrings.teddyGuineaPig.tr(),
      AppStrings.texelGuineaPig.tr(),
      AppStrings.whiteCrestedGuineaPig.tr(),
    ];

    List<String> iguanaSpecies = [
      AppStrings.unknown.tr(),
      AppStrings.angelIslandChuckwalla.tr(),
      AppStrings.blueIguana.tr(),
      AppStrings.brachylophusBulabula.tr(),
      AppStrings.brachylophusFasciatus.tr(),
      AppStrings.commonChuckwalla.tr(),
      AppStrings.ctenosauraBakeri.tr(),
      AppStrings.ctenosauraFlavidorsalis.tr(),
      AppStrings.ctenosauraPalearis.tr(),
      AppStrings.ctenosauraPectinata.tr(),
      AppStrings.ctenosauraQuinquecarinata.tr(),
      AppStrings.cycluraNubila.tr(),
      AppStrings.desertIguana.tr(),
      AppStrings.fijiCrestedIguana.tr(),
      AppStrings.greenIguana.tr(),
      AppStrings.lesserAntilleanIguana.tr(),
      AppStrings.northernBahamianRockIguana.tr(),
      AppStrings.rhinocerosIguana.tr(),
      AppStrings.yucatanSpinyTailedIguana.tr(),
    ];

    List<String> mouseRatSpecies = [
      AppStrings.unknown.tr(),
      AppStrings.africanPygmyMouse.tr(),
      AppStrings.blackRat.tr(),
      AppStrings.brownRat.tr(),
      AppStrings.cairoSpinyMouse.tr(),
      AppStrings.ceylonSpinyMouse.tr(),
      AppStrings.creteSpinyMouse.tr(),
      AppStrings.gairdnersShrewmouse.tr(),
      AppStrings.gambianPouchedRat.tr(),
      AppStrings.houseMouse.tr(),
      AppStrings.macedonianMouse.tr(),
      AppStrings.mattheysMouse.tr(),
      AppStrings.mongolianGerbil.tr(),
      AppStrings.natalMultimammateMouse.tr(),
      AppStrings.summitRat.tr(),
      AppStrings.temmincksMouse.tr(),
      AppStrings.turkestanRat.tr(),
    ];

    List<String> otterSpecies = [
      AppStrings.unknown.tr(),
      AppStrings.africanClawlessOtter.tr(),
      AppStrings.americanMink.tr(),
      AppStrings.asianSmallClawedOtter.tr(),
      AppStrings.eurasianOtter.tr(),
      AppStrings.giantOtter.tr(),
      AppStrings.hairyNosedOtter.tr(),
      AppStrings.marineOtter.tr(),
      AppStrings.neotropicalOtter.tr(),
      AppStrings.northAmericanRiverOtter.tr(),
      AppStrings.seaOtter.tr(),
      AppStrings.smoothCoatedOtter.tr(),
      AppStrings.southernRiverOtter.tr(),
      AppStrings.spottedNeckedOtter.tr(),
    ];

    List<String> rabbitSpecies = [
      AppStrings.unknown.tr(),
      AppStrings.alaskaRabbit.tr(),
      AppStrings.americanFuzzyLop.tr(),
      AppStrings.americanRabbit.tr(),
      AppStrings.annamiteStripedRabbit.tr(),
      AppStrings.appalachianCottontail.tr(),
      AppStrings.brushRabbit.tr(),
      AppStrings.bunyoroRabbit.tr(),
      AppStrings.cashmereLop.tr(),
      AppStrings.checkeredGiantRabbit.tr(),
      AppStrings.commonTapeti.tr(),
      AppStrings.deilenaar.tr(),
      AppStrings.desertCottontail.tr(),
      AppStrings.dicesCottontail.tr(),
      AppStrings.easternCottontail.tr(),
      AppStrings.europeanRabbit.tr(),
      AppStrings.flemishGiantRabbit.tr(),
      AppStrings.floridaWhiteRabbit.tr(),
      AppStrings.hollandLop.tr(),
      AppStrings.jerseyWooly.tr(),
      AppStrings.marshRabbit.tr(),
      AppStrings.mexicanCottontail.tr(),
      AppStrings.miniLop.tr(),
      AppStrings.mountainCottontail.tr(),
      AppStrings.netherlandDwarfRabbit.tr(),
      AppStrings.newEnglandCottontail.tr(),
      AppStrings.omiltemeCottontail.tr(),
      AppStrings.polishRabbit.tr(),
      AppStrings.pygmyRabbit.tr(),
      AppStrings.riverineRabbit.tr(),
      AppStrings.sumatranStripedRabbit.tr(),
      AppStrings.swampRabbit.tr(),
      AppStrings.tresMariasCottontail.tr(),
      AppStrings.volcanoRabbit.tr(),
    ];

    List<String> tortoiseSpecies = [
      AppStrings.unknown.tr(),
      AppStrings.africanSpurredTortoise.tr(),
      AppStrings.aldabraGiantTortoise.tr(),
      AppStrings.asianForestTortoise.tr(),
      AppStrings.bellsHingeBackTortoise.tr(),
      AppStrings.bolsonTortoise.tr(),
      AppStrings.burmeseStarTortoise.tr(),
      AppStrings.chacoTortoise.tr(),
      AppStrings.egyptianTortoise.tr(),
      AppStrings.greekTortoise.tr(),
      AppStrings.hermannsTortoise.tr(),
      AppStrings.homesHingeBackTortoise.tr(),
      AppStrings.homopusAreolatus.tr(),
      AppStrings.homopusFemoralis.tr(),
      AppStrings.impressedTortoise.tr(),
      AppStrings.indianStarTortoise.tr(),
      AppStrings.leopardTortoise.tr(),
      AppStrings.marginatedTortoise.tr(),
      AppStrings.pancakeTortoise.tr(),
      AppStrings.ploughshareTortoise.tr(),
      AppStrings.radiatedTortoise.tr(),
      AppStrings.redFootedTortoise.tr(),
      AppStrings.russianTortoise.tr(),
      AppStrings.speckledCapeTortoise.tr(),
      AppStrings.spiderTortoise.tr(),
      AppStrings.texasTortoise.tr(),
      AppStrings.yellowFootedTortoise.tr(),
    ];

    animalMap = {
      AppStrings.bird.tr(): [birdSpecies, birdValueSpecies],
      AppStrings.cat.tr(): [catSpecies, catValueSpecies],
      AppStrings.dog.tr(): [dogSpecies, dogValueSpecies],
      AppStrings.ferret.tr(): [ferretSpecies, ferretValueSpecies],
      AppStrings.fish.tr(): [fishSpecies, fishValueSpecies],
      AppStrings.guineaPig.tr(): [guineaPigSpecies, guineaPigValueSpecies],
      AppStrings.horse.tr(): [horseSpecies, horseValueSpecies],
      AppStrings.iguana.tr(): [iguanaSpecies, iguanaValueSpecies],
      AppStrings.mouseRat.tr(): [mouseRatSpecies, mouseRatValueSpecies],
      AppStrings.otter.tr(): [otterSpecies, otterValueSpecies],
      AppStrings.rabbit.tr(): [rabbitSpecies, rabbitValueSpecies],
      AppStrings.tortoise.tr(): [tortoiseSpecies, tortoiseValueSpecies],
    };

    // _selectedSpeciesList = birdSpecies;
    // print('changed');

    super.build(context);
    return AbsorbPointer(
      absorbing: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text(AppStrings.registerAdoption).tr(),
        ),
        body: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: ListView(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
            children: [
              Center(
                child: Stack(
                  children: [
                    _image == null
                        ? CircleAvatar(
                            radius: 60,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: const Icon(
                              Icons.pets_rounded,
                              color: Colors.white,
                              size: 50,
                            ),
                          )
                        : CircleAvatar(
                            radius: 60,
                            backgroundColor: Theme.of(context).primaryColor,
                            backgroundImage: MemoryImage(_image!),
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        child: const CircleAvatar(
                          radius: 16,
                          child: Icon(Icons.add),
                        ),
                        onTap: () async {
                          Uint8List? image = await pickImage(shouldCrop: true);
                          if (image != null) {
                            setState(() {
                              _image = image;
                            });
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              CupertinoSlidingSegmentedControl(
                padding: const EdgeInsets.all(5),
                children: {
                  Gender.Male: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        AppStrings.male,
                      ).tr(),
                      const Icon(
                        Icons.male_rounded,
                        color: Colors.lightBlue,
                      ),
                    ],
                  ),
                  Gender.Female: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        AppStrings.female,
                      ).tr(),
                      const Icon(
                        Icons.female_rounded,
                        color: Colors.pinkAccent,
                      ),
                    ],
                  ),
                },
                groupValue: _selectedGender,
                onValueChanged: (Gender? value) {
                  if (value != null) {
                    setState(() {
                      _selectedGender = value;
                    });
                  }
                },
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Text(
                AppStrings.petName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ).tr(),
              const SizedBox(
                height: 15.0,
              ),
              AdoptionFormField(
                  color: nameColor,
                  hintText: AppStrings.enterPetName.tr(),
                  keyboardType: TextInputType.name,
                  focusNode: _petNameFocusNode,
                  controller: _petNameTextEditingController),
              const SizedBox(
                height: 20.0,
              ),
              const Text(
                AppStrings.petAge,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ).tr(),
              const SizedBox(
                height: 15.0,
              ),
              AdoptionFormField(
                color: ageColor,
                hintText: AppStrings.enterPetAge.tr(),
                keyboardType: TextInputType.number,
                focusNode: _petAgeFocusNode,
                controller: _petAgeTextEditingController,
                interactionEnabled: false,
                isSeparatorNeeded: true,
                maxCharacters: 2,
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Text(
                AppStrings.petClass,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ).tr(),
              const SizedBox(
                height: 15.0,
              ),
              DropdownSearch<String>(
                popupProps: PopupProps.modalBottomSheet(
                  modalBottomSheetProps: ModalBottomSheetProps(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  showSelectedItems: true,
                  // disabledItemFn: (String s) => s.startsWith('I'),
                ),
                items: animalClass,
                // dropdownSearchDecoration: InputDecoration(
                //   labelText: "Menu mode",
                //   hintText: "country in menu mode",
                // ),
                onChanged: petClassSelected,
                selectedItem: animalClass[0],
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Text(
                AppStrings.petSpecies,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ).tr(),
              const SizedBox(
                height: 15.0,
              ),
              DropdownSearch<String>(
                key: _firstSpeciesKey,
                popupProps: PopupProps.modalBottomSheet(
                  modalBottomSheetProps: ModalBottomSheetProps(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  showSelectedItems: true,
                  showSearchBox: true,
                  // disabledItemFn: (String s) => s.startsWith('I'),
                ),
                items: _selectedSpeciesList,
                // dropdownSearchDecoration: InputDecoration(
                //   labelText: "Menu mode",
                //   hintText: "country in menu mode",
                // ),
                onChanged: (value) {
                  setState(() {
                    if (_firstSpeciesKey.currentState!.getSelectedItem ==
                        AppStrings.unknown.tr()) {
                      _isEnabled = false;
                      _isHybrid = false;
                      _secondSpeciesKey.currentState!
                          .changeSelectedItem(AppStrings.unknown.tr());
                    } else {
                      _isEnabled = true;
                      _secondSpeciesKey.currentState!.removeItem(value!);
                    }
                  });
                },
                selectedItem: _selectedSpeciesList[0],
              ),
              const SizedBox(height: 10.0),
              ListTile(
                title: const Text(
                  AppStrings.hybrid,
                ).tr(),
                leading: Checkbox(
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: _isEnabled
                      ? (bool? value) {
                          if (value != null) {
                            if (value == false) {
                              _secondSpeciesKey.currentState!
                                  .changeSelectedItem(AppStrings.unknown.tr());
                            }
                            setState(() {
                              _isHybrid = value;
                            });
                          }
                        }
                      : null,
                  value: _isHybrid,
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              DropdownSearch<String>(
                key: _secondSpeciesKey,
                enabled: _isHybrid,
                popupProps: PopupProps.modalBottomSheet(
                  modalBottomSheetProps: ModalBottomSheetProps(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  showSelectedItems: true,
                  showSearchBox: true,
                  // disabledItemFn: (String s) => s.startsWith(_firstOption),
                ),
                items: _selectedSpeciesList,
                // dropdownSearchDecoration: InputDecoration(
                //   labelText: "Menu mode",
                //   hintText: "country in menu mode",
                // ),
                onChanged: (value) {
                  if (value != null) {
                    if (value == AppStrings.unknown.tr()) {
                      setState(() {
                        _isHybrid = false;
                      });
                    }
                  }
                },
                selectedItem: _selectedSpeciesList[0],
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Text(
                AppStrings.price,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ).tr(),
              const SizedBox(
                height: 15.0,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 100.0,
                    height: 50.0,
                    child: ElevatedButton(
                        onPressed: _popCurrencyPicker, child: Text(_currency)),
                  ),
                  const SizedBox(
                    width: 25.0,
                  ),
                  Expanded(
                    child: AdoptionFormField(
                      color: priceColor,
                      isTextCentered: true,
                      isSeparatorNeeded: true,
                      focusNode: _priceFocusNode,
                      controller: _priceTextEditingController,
                      keyboardType: TextInputType.number,
                      hintText: AppStrings.enterPrice.tr(),
                      interactionEnabled: false,
                      maxCharacters: 9,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Text(
                AppStrings.description,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ).tr(),
              const SizedBox(
                height: 15.0,
              ),
              AdoptionFormField(
                color: descriptionColor,
                maxLines: 5,
                focusNode: _descriptionFocusNode,
                controller: _descriptionTextEditingController,
                keyboardType: TextInputType.multiline,
                hintText: AppStrings.enterDescription.tr(),
              ),
              const SizedBox(
                height: 20.0,
              ),
              SafeArea(
                child: Center(
                  child: SizedBox(
                    height: 50,
                    width: 170,
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: ElevatedButton.icon(
                        onPressed: () => registerPet(context, user.uid,
                            user.username, user.uid, user.email, user.photoUrl),
                        icon: _isLoading
                            ? const SpinKitCircle(
                                color: Colors.white,
                                size: 24.0,
                              )
                            : const Icon(
                                Icons.arrow_right_alt_sharp,
                              ),
                        label: const Text(AppStrings.registerPet).tr(),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
