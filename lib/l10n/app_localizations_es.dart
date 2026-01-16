// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'MoneyFit';

  @override
  String get onboardingTitle1 => 'Adiós a las hojas de cálculo complicadas';

  @override
  String get onboardingDescription1 =>
      'Gestiona tus gastos diarios fácilmente y crea hábitos de consumo saludables.';

  @override
  String get onboardingTitle2 => 'Tu presupuesto diario de un vistazo';

  @override
  String get onboardingDescription2 =>
      'Controla tu presupuesto restante del día y empieza a gastar con consciencia.';

  @override
  String get onboardingTitle3 => 'Convierte logros en hábitos duraderos';

  @override
  String get onboardingDescription3 =>
      'Transforma los desafíos diarios en logros y disfruta gestionando tu dinero.';

  @override
  String get next => 'Siguiente';

  @override
  String get dailyBudgetSetupTitle => 'Configura tu presupuesto';

  @override
  String get budgetSetupDescription =>
      'Establece tu presupuesto de gastos discrecionales. Los gastos discrecionales son el dinero que puedes usar libremente, excluyendo costos fijos como facturas, gastos médicos, vivienda y seguros.';

  @override
  String get dailyBudgetLabel => 'Presupuesto diario';

  @override
  String get monthlyBudgetLabel => 'Presupuesto mensual';

  @override
  String get enterBudgetPrompt => 'Por favor, introduce tu presupuesto.';

  @override
  String get enterValidNumberPrompt => 'Por favor, introduce un número válido.';

  @override
  String get budgetGreaterThanZeroPrompt =>
      'El presupuesto debe ser mayor que 0.';

  @override
  String get start => 'Comenzar';

  @override
  String errorOccurred(Object error) {
    return 'Ha ocurrido un error: $error';
  }

  @override
  String get dateFormat => 'd \'de\' MMMM \'de\' yyyy, EEEE';

  @override
  String get dailyDiscretionarySpending => 'Gasto discrecional diario: ';

  @override
  String get monthlyDiscretionarySpending2 => 'Gasto discrecional mensual: ';

  @override
  String get dailyBudget => 'Presupuesto discrecional diario: ';

  @override
  String get monthlyBudget => 'Presupuesto discrecional mensual: ';

  @override
  String get monthlyAvgDiscSpending => 'Disc/Día (Mes)';

  @override
  String get consecutiveDays => 'Racha de éxitos';

  @override
  String days(Object count) {
    return '$count días';
  }

  @override
  String get viewTodaySpending => 'Ver gastos\nde hoy';

  @override
  String totalSpendingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gastos',
      one: '1 gasto',
      zero: 'Sin gastos aún',
    );
    return '$_temp0';
  }

  @override
  String get addExpense => 'Añadir\ngasto de hoy';

  @override
  String get addNewExpensePrompt => 'Añade un nuevo gasto';

  @override
  String get notificationDialogTitle =>
      'Te ayudaremos a recordar registrar tus gastos';

  @override
  String get notificationDialogDescription =>
      'Registrar gastos es fácil, pero también es fácil olvidarlo. Te enviaremos recordatorios diarios para ayudarte. ¿Quieres recibir notificaciones?';

  @override
  String get notificationDialogDeny => 'No, gracias';

  @override
  String get notificationDialogConfirm => 'Sí, por favor';

  @override
  String get category_food => 'Comida';

  @override
  String get category_traffic => 'Transporte';

  @override
  String get category_insurance => 'Seguros';

  @override
  String get category_necessities => 'Necesidades';

  @override
  String get category_communication => 'Comunicación';

  @override
  String get category_housing => 'Vivienda/Servicios';

  @override
  String get category_medical => 'Médico';

  @override
  String get category_finance => 'Finanzas';

  @override
  String get categoryEatingOut => 'Comer fuera';

  @override
  String get category_cafe => 'Café/Snacks';

  @override
  String get category_shopping => 'Compras';

  @override
  String get category_hobby => 'Ocio/Hobbies';

  @override
  String get category_travel => 'Viajes/Descanso';

  @override
  String get category_subscribe => 'Suscripciones';

  @override
  String get category_beauty => 'Belleza';

  @override
  String get expenseType_essential => 'Esencial';

  @override
  String get expenseType_discretionary => 'Discrecional';

  @override
  String get dailyExpenseHistory => 'Historial de gastos diarios';

  @override
  String get noExpenseHistory => 'No se encontró historial de gastos.';

  @override
  String get editDeleteExpense => 'Editar/Eliminar gasto';

  @override
  String editDeleteExpensePrompt(Object expenseName) {
    return '¿Qué quieres hacer con el gasto \"$expenseName\"?';
  }

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get allExpenses => 'Todos los gastos';

  @override
  String get allCategories => 'Todas las categorías';

  @override
  String get unknown => 'Desconocido';

  @override
  String get ascending => 'Asc';

  @override
  String get descending => 'Desc';

  @override
  String get noExpenseData => 'No hay datos de gastos';

  @override
  String get changeFilterPrompt =>
      'Intenta cambiar los filtros o añade un nuevo gasto';

  @override
  String get allFieldsRequired =>
      'Por favor, completa todos los campos correctamente.';

  @override
  String get addNewCategory => 'Añadir nueva categoría';

  @override
  String get cancel => 'Cancelar';

  @override
  String get add => 'Añadir';

  @override
  String get deleteCategory => 'Eliminar categoría';

  @override
  String deleteCategoryPrompt(Object categoryName) {
    return '¿Estás seguro de que quieres eliminar la categoría \'$categoryName\'?';
  }

  @override
  String get pleaseWait => 'Por favor, espera...';

  @override
  String get noDataExists => 'No hay datos.';

  @override
  String get reset => 'Restablecer';

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String yearLabel(Object year) {
    return '$year';
  }

  @override
  String monthLabel(Object month) {
    return '$month';
  }

  @override
  String get confirm => 'Confirmar';

  @override
  String get budgetSetting => 'Configuración de presupuesto';

  @override
  String get save => 'Guardar';

  @override
  String get resetInformation => 'Restablecer información';

  @override
  String get notificationPermissionRequired =>
      'Permiso de notificación requerido';

  @override
  String get notificationPermissionDescription =>
      'Para usar las notificaciones, permite los permisos en la configuración.';

  @override
  String get goToSettings => 'Ir a Configuración';

  @override
  String get monthlyDiscretionarySpending => 'Discrecional';

  @override
  String get monthlyEssentialSpending => 'Esencial';

  @override
  String get success => 'Éxito';

  @override
  String get failure => 'Fallo';

  @override
  String get consecutiveSuccess => 'Racha';

  @override
  String daysCount(Object count) {
    return '$count días';
  }

  @override
  String yearMonth(Object month, Object year) {
    return '$month $year';
  }

  @override
  String get nameIsEmpty => 'El nombre está vacío.';

  @override
  String get invalidAmount =>
      'La cantidad no es válida o es menor o igual a 0.';

  @override
  String get categoryNotSelected => 'Categoría no seleccionada.';

  @override
  String formValidationError(Object error) {
    return 'Error de validación: $error';
  }

  @override
  String get registerExpense => 'Registrar gasto';

  @override
  String get register => 'Registrar';

  @override
  String get date => 'Fecha';

  @override
  String get expenseName => 'Nombre del gasto';

  @override
  String get enterExpenseName => 'Introduce el nombre del gasto';

  @override
  String get amount => 'Cantidad';

  @override
  String get enterExpenseAmount => 'Introduce la cantidad del gasto';

  @override
  String get expenseType => 'Tipo de gasto';

  @override
  String get essentialExpense => 'Esencial';

  @override
  String get discretionaryExpense => 'Discrecional';

  @override
  String get categoryName => 'Nombre de categoría';

  @override
  String get sunday => 'Dom';

  @override
  String get monday => 'Lun';

  @override
  String get tuesday => 'Mar';

  @override
  String get wednesday => 'Mié';

  @override
  String get thursday => 'Jue';

  @override
  String get friday => 'Vie';

  @override
  String get saturday => 'Sáb';

  @override
  String errorWithMessage(Object error) {
    return 'Error: $error';
  }

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get themeColor => 'Color del tema';

  @override
  String get themeColorDescription =>
      'Personaliza el esquema de colores de la app';

  @override
  String get fontSize => 'Tamaño de fuente';

  @override
  String get fontSizeDescription =>
      'Ajusta el tamaño del texto para mejor lectura';

  @override
  String get fontSizeSmall => 'Pequeño';

  @override
  String get fontSizeMedium => 'Mediano';

  @override
  String get fontSizeLarge => 'Grande';

  @override
  String get apply => 'Aplicar';

  @override
  String get dataManagement => 'Gestión de datos';

  @override
  String get resetDataConfirmation =>
      '¿Estás seguro de que quieres restablecer todos los datos? Esta acción no se puede deshacer.';

  @override
  String get notificationSetting => 'Configuración de notificaciones';

  @override
  String get category => 'Categoría';

  @override
  String get selectExpenseTypeFirst => 'Primero selecciona el tipo de gasto';

  @override
  String get errorLoadingCategories => 'Error al cargar categorías';

  @override
  String get queryMonth => 'Mes de consulta';

  @override
  String get remainingAmount => 'Cantidad restante';

  @override
  String get todayExpenseMessageZero => 'Registra tus gastos de hoy 😊';

  @override
  String get todayExpenseMessageGood =>
      '¡Genial! Aún te queda bastante presupuesto 🌿';

  @override
  String get todayExpenseMessageHalf =>
      '¡Has usado casi la mitad! Vamos a ser más cuidadosos ahora 🔔';

  @override
  String get todayExpenseMessageNearLimit =>
      '¡Estás cerca de superar el presupuesto de hoy! ⚠️';

  @override
  String get todayExpenseMessageOverLimit =>
      '¡Has superado el presupuesto de hoy! Ajustemos los gastos ❗';

  @override
  String get information => 'Información';

  @override
  String get writeReview => 'Escribir reseña';

  @override
  String get appVersion => 'Versión de la app';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get basicSettings => 'Configuración básica';

  @override
  String get titleAndClose => 'Título y cerrar';

  @override
  String get filterSettings => 'Configuración de filtros';

  @override
  String get sort => 'Ordenar';

  @override
  String get latest => 'Más reciente';

  @override
  String get oldest => 'Más antiguo';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get spendingByCategory => 'Gastos por categoría';

  @override
  String get top3ExpensesThisMonth => 'Top 3 gastos este mes';

  @override
  String get home => 'Inicio';

  @override
  String get daily => 'Diario';

  @override
  String get monthly => 'Mensual';

  @override
  String get calendar => 'Calendario';

  @override
  String get stats => 'Estadísticas';

  @override
  String get expense => 'Gastos';

  @override
  String get settings => 'Ajustes';

  @override
  String get notificationTitleDaily => 'Recordatorio de gastos diarios';

  @override
  String get notificationBodyMorning =>
      '¡Buenos días! ☀️ ¿Listo para registrar tu primer gasto del día? ¡Los pequeños hábitos hacen grandes diferencias!';

  @override
  String get notificationBodyAfternoon =>
      '¿Disfrutaste tu almuerzo? 🍱 ¿Qué tal una actualización rápida de tus gastos?';

  @override
  String get notificationBodyNight =>
      'El día casi termina 🌙 Cierra tu día organizando tus gastos.';

  @override
  String get resetComplete => 'Gracias por usar MoneyFit.';

  @override
  String get upgraderTitle => 'Actualización disponible';

  @override
  String get upgraderBody =>
      'Hay una nueva versión disponible. Por favor, actualiza para una mejor experiencia.';

  @override
  String get upgraderPrompt => '¿Quieres actualizar ahora?';

  @override
  String get upgraderButtonLater => 'Más tarde';

  @override
  String get upgraderButtonUpdate => 'Actualizar ahora';

  @override
  String get upgraderButtonIgnore => 'Ignorar';

  @override
  String get updateRequiredTitle => 'Actualización requerida';

  @override
  String get updateRequiredBody =>
      'Por favor, actualiza a la última versión para la mejor experiencia.';

  @override
  String get updateAvailableBody =>
      'Hay una nueva versión disponible. Disfruta de las últimas funciones y mejoras.';

  @override
  String get updateChangelogTitle => 'Novedades';

  @override
  String get updateButton => 'Actualizar';

  @override
  String get updateDetails => 'Detalles';

  @override
  String get updateSheetTitle => 'Info de actualización';

  @override
  String get updateButtonGo => 'Ir a actualizar';

  @override
  String get review_modal_binary_title =>
      '¿Estás satisfecho con la app hasta ahora?';

  @override
  String get review_modal_button_good => 'Me gustó';

  @override
  String get review_modal_button_bad => 'No mucho';

  @override
  String get review_positive_title => '¿Podrías decirnos qué te gustó?';

  @override
  String get review_positive_button_yes => 'Claro';

  @override
  String get review_button_later => 'Más tarde';

  @override
  String get review_button_never => 'No mostrar de nuevo';

  @override
  String get review_negative_title =>
      'Por favor, cuéntanos qué no funcionó para ti.';

  @override
  String get review_negative_hint => 'Cuéntanos qué fue inconveniente.';

  @override
  String get review_negative_button_send => 'Enviar';

  @override
  String get review_thanks_message =>
      'Gracias por tu opinión. Trabajaremos para mejorarlo.';

  @override
  String get monthlyExpenseMessageZero =>
      '¡Aún no hay gastos discrecionales este mes!';

  @override
  String get monthlyExpenseMessageGood =>
      '¡Tu presupuesto está bien gestionado este mes!';

  @override
  String get monthlyExpenseMessageHalf =>
      'Has usado aproximadamente la mitad de tu presupuesto este mes.';

  @override
  String get monthlyExpenseMessageNearLimit =>
      'Tu presupuesto está casi agotado este mes.';

  @override
  String get monthlyExpenseMessageOverLimit =>
      'Has superado tu presupuesto este mes.';

  @override
  String get contactUs => 'Contáctanos';

  @override
  String get inquiryType => 'Tipo de consulta';

  @override
  String get inquiryTypeBugReport => 'Reporte de error';

  @override
  String get inquiryTypeFeatureSuggestion => 'Sugerencia de función';

  @override
  String get inquiryTypeGeneralInquiry => 'Consulta general';

  @override
  String get inquiryTypeOther => 'Otro';

  @override
  String get replyEmail => 'Email para respuesta';

  @override
  String get optional => 'Opcional';

  @override
  String get inquiryDetails => 'Detalles de la consulta';

  @override
  String get submit => 'Enviar';

  @override
  String get inquirySuccess => 'Tu consulta se ha enviado correctamente.';

  @override
  String get inquiryFailure => 'Error al enviar tu consulta.';

  @override
  String get invalidEmail => 'Por favor, introduce un email válido.';

  @override
  String get fieldRequired => 'Este campo es obligatorio.';

  @override
  String get selectThemeColor => 'Seleccionar color del tema';

  @override
  String get quickSelect => 'Selección rápida';

  @override
  String get recentColors => 'Colores recientes';

  @override
  String get customSelect => 'Selección personalizada';

  @override
  String get close => 'Cerrar';

  @override
  String get languageSetting => 'Idioma y moneda';

  @override
  String get selectLanguage => 'Seleccionar idioma';
}
