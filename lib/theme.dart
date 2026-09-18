import 'package:flutter/material.dart';

//---------------------- app theme colors ---------------------
const Color purpleBackground = Color(0xFF805AFF);
const Color lavenderBackground = Color(0xFFF2F1FE);
const Color greyBackground = Color(0xFFF5F5F5);
// const Color greyBackground = Colors.grey;

//------------------------ text colors ------------------------
const Color textColorLavender = Color(0xFF805AFF);
const Color textColorRed = Color(0xFFF76767);
const Color textColorBlack = Colors.black;

//--------------------------- Fonts  --------------------------
const String SfProDisplay='SfProDisplay';
const FontWeight SfProRegular=FontWeight.w400;
const FontWeight SfProMedium=FontWeight.w500;
const FontWeight SfProBold=FontWeight.w700;

Color appSurfaceColor(BuildContext context) => appContainerColor(context);

Color appTextColor(BuildContext context) =>
	Theme.of(context).colorScheme.onSurface;

Color appContainerColor(BuildContext context) =>
	Theme.of(context).brightness == Brightness.light
		? greyBackground
		: Theme.of(context).colorScheme.surfaceContainerHighest;

Color appAccentContainerColor(BuildContext context) =>
	Theme.of(context).brightness == Brightness.light
		? lavenderBackground
		: const Color(0xFF2A2340);

Color appIconColor(BuildContext context) =>
	Theme.of(context).brightness == Brightness.dark
		? Colors.white
		: const Color(0xFF4A4650);

Color homeSectionColor(BuildContext context) =>
	Theme.of(context).brightness == Brightness.dark
		? const Color(0xFF3A3A3A)
		: greyBackground;

Color homeInnerColor(BuildContext context) =>
	Theme.of(context).brightness == Brightness.dark
		? Colors.black
		: Colors.white;

Color appDividerColor(BuildContext context) =>
	Theme.of(context).dividerColor;

ThemeData buildLightTheme() {
	return ThemeData(
		brightness: Brightness.light,
		fontFamily: SfProDisplay,
		scaffoldBackgroundColor: Colors.white,
		colorScheme: ColorScheme.fromSeed(
			seedColor: purpleBackground,
			brightness: Brightness.light,
			surface: Colors.white,
		),
		iconTheme: const IconThemeData(color: Color(0xFF4A4650)),
		dividerColor: const Color(0xFFE5E2EC),
		inputDecorationTheme: const InputDecorationTheme(
			hintStyle: TextStyle(color: Color(0xFF77727F)),
		),
	);
}

ThemeData buildDarkTheme() {
	return ThemeData(
		brightness: Brightness.dark,
		fontFamily: SfProDisplay,
		scaffoldBackgroundColor: const Color(0xFF121017),
		colorScheme: ColorScheme.fromSeed(
			seedColor: purpleBackground,
			brightness: Brightness.dark,
			surface: const Color(0xFF1D1925),
			onSurface: const Color(0xFFF4F1FA),
		),
		iconTheme: const IconThemeData(color: Color(0xFFE8E2F0)),
		dividerColor: const Color(0xFF3A3444),
		inputDecorationTheme: const InputDecorationTheme(
			hintStyle: TextStyle(color: Color(0xFFAAA4B5)),
		),
	);
}