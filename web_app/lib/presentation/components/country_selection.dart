import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme/app_colors.dart';
import '../../mockdata.dart';
import 'item_langauge.dart';

class CountrySelection extends StatefulWidget {
  final List<String> data;
  final ValueChanged<int?> onChanged;
  final List<int> selectedCountries;
  const CountrySelection(
      {super.key,
      required this.data,
      required this.onChanged,
      required this.selectedCountries});

  @override
  State<CountrySelection> createState() => _CountrySelectionState();
}

class _CountrySelectionState extends State<CountrySelection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsetsDirectional.only(end: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF000000), width: 1),
        borderRadius: BorderRadius.circular(
          5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          padding: EdgeInsets.zero,
          buttonColor: Colors.white,
          child: DropdownButton2(
            isExpanded: true,
            hint: Text("Country",
                style: Theme.of(Get.context!)
                    .textTheme
                    .labelMedium!
                    .copyWith(fontSize: 12, fontWeight: FontWeight.w500)),
            dropdownStyleData: DropdownStyleData(
              offset: const Offset(5, -50),
              padding: const EdgeInsets.only(bottom: 5, top: 10),
              openInterval: const Interval(0.25, 0.5, curve: Curves.easeIn),
              decoration: BoxDecoration(
                  color: Get.theme.colorScheme.onSecondaryContainer,
                  borderRadius: BorderRadius.circular(
                    5,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(8, 16))
                  ]),
              isOverButton: true,
            ),
            value: null,
            selectedItemBuilder: (BuildContext context) {
              return country.map((value) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: Get.height / 100 * 0.5,
                      horizontal: Get.width / 100 * 0.2),
                  child: ItemCountry(
                      flag: value["flag"]!,
                      function: () {
                        widget.onChanged(value["id"]);
                      },
                      isSelected:
                          widget.selectedCountries.contains(value["id"]),
                      text: value["countryName"]!),
                );
              }).toList();
            },
            items: country.map((value) {
              return DropdownMenuItem(
                  value: value["countryName"],
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: Get.height / 100 * 0.5,
                        horizontal: Get.width / 100 * 0.2),
                    child: ItemCountry(
                        flag: value["flag"]!,
                        function: () {
                          widget.onChanged(value["id"]);
                        },
                        isSelected:
                            widget.selectedCountries.contains(value["id"]),
                        text: value["countryName"]!),
                  ));
            }).toList(),
            onChanged: (value) {
              print(value);
            },
          ),
        ),
      ),
    );
  }
}

class ProviderSelection extends StatelessWidget {
  final ValueChanged<String?> onChanged;
  final List<String> data;
  final String selectedLabel;
  const ProviderSelection(
      {super.key,
      required this.onChanged,
      required this.data,
      required this.selectedLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsetsDirectional.only(end: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF000000), width: 1),
        borderRadius: BorderRadius.circular(
          5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          padding: EdgeInsets.zero,
          buttonColor: Colors.white,
          child: DropdownButton2(
            isExpanded: true,
            hint: Text(selectedLabel,
                style: Theme.of(Get.context!)
                    .textTheme
                    .labelMedium!
                    .copyWith(fontSize: 12, fontWeight: FontWeight.w500)),
            dropdownStyleData: DropdownStyleData(
              offset: const Offset(5, -50),
              padding: const EdgeInsets.only(bottom: 5, top: 10),
              openInterval: const Interval(0.25, 0.5, curve: Curves.easeIn),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    5,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(8, 16))
                  ]),
              isOverButton: true,
            ),
            value: null,
            items: (data).map((value) {
              return DropdownMenuItem(
                  value: value,
                  child: Row(
                    children: [
                      Text(value,
                          style: Theme.of(Get.context!)
                              .textTheme
                              .labelMedium!
                              .copyWith(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ));
            }).toList(),
            onChanged: (value) => onChanged(value),
          ),
        ),
      ),
    );
  }
}
