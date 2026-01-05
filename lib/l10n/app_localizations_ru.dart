// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get signInTitle => 'Войти';

  @override
  String get emailOrUsername => 'Эл. почта или имя пользователя';

  @override
  String get enterEmailOrUsername => 'Введите эл. почту или имя пользователя';

  @override
  String get password => 'Пароль';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get orContinueWith => 'Или продолжить с';

  @override
  String get signInButton => 'Войти';

  @override
  String get dontHaveAccount => 'Ещё нет аккаунта? ';

  @override
  String get signUp => 'Зарегистрироваться';

  @override
  String get errEnterEmailOrUsername => 'Пожалуйста, введите эл. почту или имя пользователя';

  @override
  String get errEnterPassword => 'Пожалуйста, введите пароль';

  @override
  String get chooseLanguageTitle => 'Выберите язык';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageGerman => 'Немецкий';

  @override
  String get languageSpanish => 'Испанский';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageTurkish => 'Турецкий';

  @override
  String get languageFrench => 'Французский';

  @override
  String get signUpTitle => 'Регистрация';

  @override
  String get signUpButton => 'Зарегистрироваться';

  @override
  String get signUpEmailLabel => 'Эл. почта';

  @override
  String get signUpEmailHint => 'Введите эл. почту';

  @override
  String get signUpUsernameLabel => 'Создайте имя пользователя';

  @override
  String get signUpUsernameHint => 'Введите имя пользователя';

  @override
  String get signUpPasswordLabel => 'Создайте пароль';

  @override
  String get signUpPasswordHint => 'Пароль';

  @override
  String get signUpOrContinueWith => 'Или продолжить с';

  @override
  String get signUpEmailRequired => 'Пожалуйста, введите эл. почту';

  @override
  String get signUpUsernameRequired => 'Пожалуйста, введите имя пользователя';

  @override
  String get signUpPasswordRequired => 'Пожалуйста, введите пароль';

  @override
  String get signUpErrorDefault => 'Ошибка регистрации';

  @override
  String get signUpErrorGeneric => 'Что-то пошло не так. Пожалуйста, попробуйте снова.';

  @override
  String get forgotPasswordTitle => 'Новый пароль';

  @override
  String get forgotPasswordEmailLabel => 'Эл. почта';

  @override
  String get forgotPasswordEmailHint => 'Введите эл. почту или имя пользователя';

  @override
  String get forgotPasswordNewPasswordLabel => 'Новый пароль';

  @override
  String get forgotPasswordConfirmPasswordLabel => 'Подтвердите пароль';

  @override
  String get forgotPasswordPasswordHint => 'Пароль';

  @override
  String get forgotPasswordDoneButton => 'Готово';

  @override
  String get forgotPasswordEmailRequired => 'Пожалуйста, введите эл. почту или имя пользователя';

  @override
  String get forgotPasswordNewPasswordRequired => 'Пожалуйста, введите новый пароль';

  @override
  String get forgotPasswordConfirmPasswordRequired => 'Пожалуйста, подтвердите пароль';

  @override
  String get forgotPasswordPasswordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get forgotPasswordResetEmailSent => 'Письмо для сброса пароля отправлено. Проверьте входящие.';

  @override
  String get forgotPasswordNoAccountFound => 'Аккаунт для этого адреса эл. почты не найден.';

  @override
  String get forgotPasswordInvalidEmail => 'Пожалуйста, введите корректный адрес эл. почты.';

  @override
  String get forgotPasswordNetworkError => 'Ошибка сети. Пожалуйста, попробуйте снова.';

  @override
  String get forgotPasswordFailedToSendResetEmail => 'Не удалось отправить письмо для сброса пароля.';

  @override
  String get forgotPasswordGenericError => 'Что-то пошло не так. Пожалуйста, попробуйте снова.';

  @override
  String get exploreTitle => 'Обзор';

  @override
  String get exploreMostPopularRoutines => 'Самые популярные рутины';

  @override
  String get exploreBecomeBetterYou => 'Станьте лучше';

  @override
  String get exploreHeroHeadline => 'Умные\nпроекты\nуже здесь';

  @override
  String get exploreHeroSubtitle => 'Создавайте проекты с ИИ-\nкомандой, заметками, задачами и\nфайлами';

  @override
  String get exploreHeroCta => 'Создать бесплатный проект';

  @override
  String get exploreRoutineTag => 'РУТИНА';

  @override
  String get exploreHabitsTitle => 'Привычки';

  @override
  String exploreCopyHabitsButton(int count) {
    return 'Скопировать $count привычек';
  }

  @override
  String get explorePleaseSignInToCopyHabits => 'Пожалуйста, войдите, чтобы копировать привычки.';

  @override
  String exploreCopiedHabitsSnack(int count) {
    return 'Скопировано привычек: $count';
  }

  @override
  String get exploreCouldNotCopyHabits => 'Не удалось скопировать привычки. Попробуйте снова.';

  @override
  String get exploreConfirmCopyTitle => 'Скопировать привычки?';

  @override
  String exploreConfirmCopySubtitle(int count) {
    return 'Будет создано привычек: $count.';
  }

  @override
  String get exploreYes => 'Да';

  @override
  String get exploreCancel => 'Отмена';

  @override
  String get exploreRoutineProcrastinationTitle => 'Преодолеть\nпрокрастинацию';

  @override
  String get exploreRoutineProcrastinationDescription => 'Прокрастинация может саботировать вашу продуктивность и мешать успеху, но она не обязана определять ваше будущее. Эта рутина предлагает стратегии, основанные на доказательных данных, чтобы помочь вам преодолеть прокрастинацию и набрать темп.';

  @override
  String get exploreRoutineAnxietyTitle => 'Снять\nтревожность';

  @override
  String get exploreRoutineAnxietyDescription => 'Практичная рутина, чтобы снизить базовый стресс и уменьшить тревожные циклы с помощью небольших ежедневных действий.';

  @override
  String get exploreRoutineFocusBoostTitle => 'Усиление\nфокуса';

  @override
  String get exploreRoutineFocusBoostDescription => 'Укрепляйте концентрацию с помощью компактной рутины, разработанной для глубокой работы.';

  @override
  String get exploreRoutineMorningMomentumTitle => 'Утренний\nразгон';

  @override
  String get exploreRoutineMorningMomentumDescription => 'Начните день с импульсом и чётким планом.';

  @override
  String get exploreHabitPomodoroTitle => 'Техника Помодоро';

  @override
  String get exploreHabitPomodoroSubtitle => 'Используйте 25-минутные блоки фокусировки с короткими перерывами.';

  @override
  String get exploreHabitTimeBlockingTitle => 'Тайм-блокинг';

  @override
  String get exploreHabitTimeBlockingSubtitle => 'Распланируйте день по понятным временным окнам задач.';

  @override
  String get exploreHabitEatThatFrogTitle => 'Съешь лягушку';

  @override
  String get exploreHabitEatThatFrogSubtitle => 'Сделайте самую сложную задачу первой, чтобы снизить избегание.';

  @override
  String get exploreHabitBreakTasksTitle => 'Разбивайте задачи на маленькие шаги';

  @override
  String get exploreHabitBreakTasksSubtitle => 'Превращайте большие задачи в небольшие, выполнимые шаги.';

  @override
  String get exploreHabitSmartGoalsTitle => 'Ставьте SMART-цели';

  @override
  String get exploreHabitSmartGoalsSubtitle => 'Конкретные, измеримые, достижимые, релевантные, ограниченные по времени.';

  @override
  String get exploreHabitBoxBreathingTitle => 'Квадратное дыхание';

  @override
  String get exploreHabitBoxBreathingSubtitle => 'Дыхательный цикл 4-4-4-4.';

  @override
  String get exploreHabitShortWalkTitle => 'Короткая прогулка';

  @override
  String get exploreHabitShortWalkSubtitle => '10 минут на улице, если возможно.';

  @override
  String get exploreHabitJournalDumpTitle => 'Выгрузка в дневник';

  @override
  String get exploreHabitJournalDumpSubtitle => 'Записывайте мысли без фильтра.';

  @override
  String get exploreHabitLimitCaffeineTitle => 'Ограничьте кофеин';

  @override
  String get exploreHabitLimitCaffeineSubtitle => 'Сократите триггеры после полудня.';

  @override
  String get exploreHabitSleepWindDownTitle => 'Подготовка ко сну';

  @override
  String get exploreHabitSleepWindDownSubtitle => 'Стабильный ритуал перед сном.';

  @override
  String get exploreHabitNoPhoneStartTitle => 'Старт без телефона';

  @override
  String get exploreHabitNoPhoneStartSubtitle => 'Первые 30 минут без пролистывания.';

  @override
  String get exploreHabitDeepWorkBlockTitle => 'Блок глубокой работы';

  @override
  String get exploreHabitDeepWorkBlockSubtitle => 'Один спринт фокусировки на 45–60 минут.';

  @override
  String get exploreHabitSingleTaskListTitle => 'Список ключевых задач';

  @override
  String get exploreHabitSingleTaskListSubtitle => 'Выберите максимум 1–3 результата.';

  @override
  String get exploreHabitHydrateTitle => 'Пейте воду';

  @override
  String get exploreHabitHydrateSubtitle => 'Вода перед кофе.';

  @override
  String get exploreHabitMakeBedTitle => 'Заправьте кровать';

  @override
  String get exploreHabitMakeBedSubtitle => 'Быстрая победа на старте.';

  @override
  String get exploreHabitTop3PrioritiesTitle => 'Топ-3 приоритета';

  @override
  String get exploreHabitTop3PrioritiesSubtitle => 'Запишите результаты дня.';

  @override
  String get exploreHabitStretchTitle => 'Растяжка';

  @override
  String get exploreHabitStretchSubtitle => '2–5 минут на всё тело.';

  @override
  String get exploreHabitProteinBreakfastTitle => 'Белковый завтрак';

  @override
  String get exploreHabitProteinBreakfastSubtitle => 'Стабильная энергия.';

  @override
  String get exploreRoutineCreativityBoostTitle => 'Рутина\nдля повышения\nкреативности';

  @override
  String get exploreRoutineCreativityBoostDescription => 'Простая рутина, чтобы увеличить творческий результат и снизить трение.';

  @override
  String get exploreRoutineProductivityEnhancerTitle => 'Рутина\nдля повышения\nпродуктивности';

  @override
  String get exploreRoutineProductivityEnhancerDescription => 'Улучшайте результаты с помощью лучших привычек планирования и исполнения.';

  @override
  String get exploreRoutineBuildConfidenceTitle => 'Развить\nуверенность';

  @override
  String get exploreRoutineBuildConfidenceDescription => 'Небольшие ежедневные действия, чтобы укреплять уверенность и регулярность.';

  @override
  String get exploreRoutineBetterSleepTitle => 'Лучший\nсон';

  @override
  String get exploreRoutineBetterSleepDescription => 'Успокаивающая рутина для улучшения качества сна и восстановления.';

  @override
  String get exploreHabitIdeaCaptureTitle => 'Фиксация идей';

  @override
  String get exploreHabitIdeaCaptureSubtitle => 'Записывайте 5 идей ежедневно.';

  @override
  String get exploreHabitCreateBeforeConsumeTitle => 'Создавайте до потребления';

  @override
  String get exploreHabitCreateBeforeConsumeSubtitle => 'Сначала создавайте, потом листайте.';

  @override
  String get exploreHabitInputWalkTitle => 'Прогулка для вдохновения';

  @override
  String get exploreHabitInputWalkSubtitle => 'Пройдитесь, чтобы вдохновиться.';

  @override
  String get exploreHabitDailySketchTitle => 'Ежедневный скетч';

  @override
  String get exploreHabitDailySketchSubtitle => '2 минуты, без давления.';

  @override
  String get exploreHabitPlanTomorrowTitle => 'План на завтра';

  @override
  String get exploreHabitPlanTomorrowSubtitle => 'Пятиминутный план в конце дня.';

  @override
  String get exploreHabitInboxZeroTitle => 'Inbox Zero';

  @override
  String get exploreHabitInboxZeroSubtitle => 'Разберите сообщения одним блоком.';

  @override
  String get exploreHabitTwoMinuteRuleTitle => 'Правило двух минут';

  @override
  String get exploreHabitTwoMinuteRuleSubtitle => 'Сделайте сейчас, если это быстро.';

  @override
  String get exploreHabitShutdownRitualTitle => 'Ритуал завершения';

  @override
  String get exploreHabitShutdownRitualSubtitle => 'Закройте хвосты, завершите работу чисто.';

  @override
  String get exploreHabitDailyWinTitle => 'Победа дня';

  @override
  String get exploreHabitDailyWinSubtitle => 'Записывайте одну победу каждый день.';

  @override
  String get exploreHabitPracticeSkillTitle => 'Практикуйте навык';

  @override
  String get exploreHabitPracticeSkillSubtitle => '10 минут целенаправленной практики.';

  @override
  String get exploreHabitPostureResetTitle => 'Проверка осанки';

  @override
  String get exploreHabitPostureResetSubtitle => 'Проверка 2 раза в день.';

  @override
  String get exploreHabitPositiveReframeTitle => 'Позитивная переоценка';

  @override
  String get exploreHabitPositiveReframeSubtitle => 'Перепишите историю в своей голове.';

  @override
  String get exploreHabitNoScreensTitle => 'Без экранов';

  @override
  String get exploreHabitNoScreensSubtitle => 'Избегайте экранов за 30 минут до сна.';

  @override
  String get exploreHabitCoolRoomTitle => 'Прохладная комната';

  @override
  String get exploreHabitCoolRoomSubtitle => 'Снизьте температуру для лучшего сна.';

  @override
  String get exploreHabitReadTitle => 'Чтение';

  @override
  String get exploreHabitReadSubtitle => '10 страниц книги.';

  @override
  String get exploreHabitSameBedtimeTitle => 'Одинаковое время сна';

  @override
  String get exploreHabitSameBedtimeSubtitle => 'Регулярность важнее идеала.';

  @override
  String get createHabitCreateTitle => 'Создать привычку';

  @override
  String get createHabitEditTitle => 'Редактировать привычку';

  @override
  String get createHabitColorPicker => 'Выбор цвета';

  @override
  String get createHabitPickColorTitle => 'Выберите цвет';

  @override
  String get createHabitContinue => 'Продолжить';

  @override
  String get createHabitCancel => 'Отмена';

  @override
  String get createHabitDone => 'Готово';

  @override
  String get createHabitTitleLabel => 'Название';

  @override
  String get createHabitTitleHint => 'Название';

  @override
  String get createHabitDescriptionLabel => 'Описание';

  @override
  String get createHabitDescriptionHint => 'Описание';

  @override
  String get createHabitColorLabel => 'Цвет';

  @override
  String get createHabitRepeatLabel => 'Повтор';

  @override
  String get createHabitDaily => 'Ежедневно';

  @override
  String get createHabitWeekly => 'Еженедельно';

  @override
  String get createHabitMonthly => 'Ежемесячно';

  @override
  String get createHabitReminderLabel => 'Напоминание';

  @override
  String get createHabitSendNotificationAt => 'Отправить уведомление в';

  @override
  String get createHabitPickTime => 'Выберите время';

  @override
  String get createHabitReminderInfo => 'Вы получите «Пора заняться привычкой.» вместе с названием привычки.';

  @override
  String get createHabitGoalLabel => 'Цель';

  @override
  String get createHabitEdit => 'Изменить';

  @override
  String get createHabitPerDay => 'в день';

  @override
  String get createHabitSetGoal => 'Задать цель';

  @override
  String get createHabitTrackUnitsHelp => 'Отслеживайте разы, минуты, часы, кг, км, литры или унции.';

  @override
  String get createHabitSave => 'Сохранить';

  @override
  String get createHabitSaveChanges => 'Сохранить изменения';

  @override
  String get createHabitTitleRequired => 'Пожалуйста, введите название';

  @override
  String get createHabitMustBeSignedIn => 'Чтобы создать привычку, нужно войти в аккаунт.';

  @override
  String get createHabitFailedToSave => 'Не удалось сохранить привычку. Пожалуйста, попробуйте снова.';

  @override
  String get createHabitOnTheseDays => 'В эти дни';

  @override
  String get createHabitFrequency => 'Частота';

  @override
  String get createHabitEveryday => 'Каждый день';

  @override
  String createHabitDaysPerWeek(int count) {
    return '$count дней в неделю';
  }

  @override
  String get createHabitOnThisDayEachMonth => 'В этот день каждого месяца';

  @override
  String get createHabitMonShort => 'П';

  @override
  String get createHabitTueShort => 'В';

  @override
  String get createHabitWedShort => 'С';

  @override
  String get createHabitThuShort => 'Ч';

  @override
  String get createHabitFriShort => 'П';

  @override
  String get createHabitSatShort => 'С';

  @override
  String get createHabitSunShort => 'В';

  @override
  String get createHabitAm => 'AM';

  @override
  String get createHabitPm => 'PM';

  @override
  String createHabitGoalLabelText(int value, String unit, String plural) {
    return '$value $unit$plural в день';
  }

  @override
  String createHabitGoalText(int value, String unit) {
    return '$value $unit в день';
  }

  @override
  String get createHabitUnitTime => 'раз';

  @override
  String get createHabitUnitMinute => 'минута';

  @override
  String get createHabitUnitHour => 'час';

  @override
  String get createHabitUnitKg => 'кг';

  @override
  String get createHabitUnitKm => 'км';

  @override
  String get createHabitUnitL => 'л';

  @override
  String get createHabitUnitOz => 'унц.';

  @override
  String get habitDetailPleaseSignInHabits => 'Пожалуйста, войдите, чтобы просматривать привычки.';

  @override
  String get habitDetailPleaseSignInNotes => 'Пожалуйста, войдите, чтобы просматривать заметки.';

  @override
  String get habitDetailDefaultHabitTitle => 'Привычка';

  @override
  String get habitDetailUpdateProgress => 'Обновить прогресс';

  @override
  String get habitDetailMarkedIncompleteDay => 'Отмечено как невыполненное за этот день';

  @override
  String get habitDetailMarkedCompleteDay => 'Отмечено как выполненное за этот день';

  @override
  String get habitDetailCouldNotUpdateDay => 'Не удалось обновить этот день. Попробуйте снова.';

  @override
  String get habitDetailDeleteHabitTitle => 'Удалить привычку?';

  @override
  String get habitDetailDeleteHabitMessage => 'Это удалит привычку и её историю.';

  @override
  String get habitDetailCancel => 'Отмена';

  @override
  String get habitDetailDelete => 'Удалить';

  @override
  String get habitDetailStatScore => 'Баллы';

  @override
  String get habitDetailStatTotal => 'Всего';

  @override
  String get habitDetailStatBestStreak => 'Лучшая серия';

  @override
  String get habitDetailStatStreak => 'Серия';

  @override
  String get habitDetailScoreTitle => 'Баллы';

  @override
  String get habitDetailAnalytics => 'Аналитика';

  @override
  String get habitDetailNoDataYet => 'Данных пока нет';

  @override
  String get habitDetailHistory => 'История';

  @override
  String get habitDetailNotes => 'Заметки';

  @override
  String get habitDetailAddNote => 'Добавить заметку';

  @override
  String get habitDetailCouldNotLoadNotes => 'Не удалось загрузить заметки.';

  @override
  String get habitDetailLoading => 'Загрузка…';

  @override
  String get habitDetailNoNotesYet => 'Заметок пока нет';

  @override
  String get habitDetailDeleteNoteTitle => 'Удалить заметку?';

  @override
  String get habitDetailDeleteNoteMessage => 'Она будет удалена и из привычки, и из журнала.';

  @override
  String get habitDetailNoteDeleted => 'Заметка удалена';

  @override
  String get habitDetailNoteSaved => 'Заметка сохранена';

  @override
  String get habitDetailCouldNotSaveNote => 'Не удалось сохранить заметку. Попробуйте снова.';

  @override
  String habitDetailCouldNotSaveNoteWithCode(String code) {
    return 'Не удалось сохранить заметку: $code';
  }

  @override
  String get habitDetailToday => 'Сегодня';

  @override
  String habitDetailTodayTime(String time) {
    return 'Сегодня, $time';
  }

  @override
  String get habitDetailWhatHappenedToday => 'Что произошло сегодня?';

  @override
  String get habitDetailPickerCancel => 'Отмена';

  @override
  String get habitDetailPickerDone => 'Готово';

  @override
  String get habitDetailMonthJanShort => 'янв.';

  @override
  String get habitDetailMonthFebShort => 'февр.';

  @override
  String get habitDetailMonthMarShort => 'март';

  @override
  String get habitDetailMonthAprShort => 'апр.';

  @override
  String get habitDetailMonthMayShort => 'май';

  @override
  String get habitDetailMonthJunShort => 'июнь';

  @override
  String get habitDetailMonthJulShort => 'июль';

  @override
  String get habitDetailMonthAugShort => 'авг.';

  @override
  String get habitDetailMonthSepShort => 'сент.';

  @override
  String get habitDetailMonthOctShort => 'окт.';

  @override
  String get habitDetailMonthNovShort => 'нояб.';

  @override
  String get habitDetailMonthDecShort => 'дек.';

  @override
  String get habitsTitle => 'Привычки';

  @override
  String get habitsSnackHabitCompletedCorrectly => 'Привычка выполнена корректно';

  @override
  String get habitsSnackProgressUpdated => 'Прогресс обновлён';

  @override
  String get habitsSnackCouldNotUpdateProgress => 'Не удалось обновить прогресс. Попробуйте снова.';

  @override
  String get habitsSnackHabitDeleted => 'Привычка удалена';

  @override
  String get habitsBottomNavHome => 'Главная';

  @override
  String get habitsBottomNavAnalytics => 'Аналитика';

  @override
  String get habitsBottomNavExplore => 'Обзор';

  @override
  String get habitsTabToday => 'Сегодня';

  @override
  String get habitsTabWeekly => 'Неделя';

  @override
  String get habitsTabOverall => 'Общее';

  @override
  String get habitsNotSignedInTitle => 'Вы не вошли';

  @override
  String get habitsNotSignedInSubtitle => 'Пожалуйста, войдите, чтобы создавать привычки.';

  @override
  String get habitsGoodJobTitle => 'Отлично!';

  @override
  String get habitsAllSetAndDone => 'Всё готово.';

  @override
  String get habitsGreatButton => 'Отлично!';

  @override
  String habitsProgressCountCompleted(int count) {
    return 'Выполнено: $count';
  }

  @override
  String get habitsCompletedShown => 'Выполненные показаны';

  @override
  String get habitsCompletedHidden => 'Выполненные скрыты';

  @override
  String get habitsShowCompleted => 'Показать выполненные';

  @override
  String habitsCompletionSheetPerDay(int current, int goal, String unit, String plural) {
    return '$current / $goal $unit$plural в день';
  }

  @override
  String get habitsCompletionSheetMarkCompleted => 'Отметить как выполненное';

  @override
  String get habitsCompletionSheetSaveProgress => 'Сохранить прогресс';

  @override
  String get habitsCompletionSheetHint => 'Нажимайте + или - чтобы фиксировать разы или единицы, которые вы задали.';

  @override
  String get habitsDefaultHabitTitle => 'Привычка';

  @override
  String get habitsEmptyTitle => 'На сегодня привычек нет';

  @override
  String get habitsEmptySubtitle => 'На сегодня привычек нет. Создать?';

  @override
  String get habitsEmptyCreateButton => '+ Создать';

  @override
  String habitsWeeklyCompletedCount(int count) {
    return 'Выполнено: $count';
  }

  @override
  String get habitsOverallEveryday => 'Каждый день';

  @override
  String get habitsOverallWeeklyHabit => 'Еженедельная привычка';

  @override
  String get habitsOverallMonthlyHabit => 'Ежемесячная привычка';

  @override
  String get habitsGoalUnitTime => 'раз';

  @override
  String get journalSignInPrompt => 'Пожалуйста, войдите, чтобы просматривать журнал.';

  @override
  String get journalTitle => 'Журнал';

  @override
  String get journalEmptyTitle => 'Заметок пока нет';

  @override
  String get journalEmptySubtitle => 'Добавьте заметку, чтобы начать';

  @override
  String get journalAddButton => '+ Добавить';

  @override
  String get journalComposerHint => 'Что произошло сегодня?';

  @override
  String get journalToday => 'Сегодня';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonDone => 'Готово';

  @override
  String get journalDeleteNoteTitle => 'Удалить заметку?';

  @override
  String get journalDeleteNoteBody => 'Это действие нельзя отменить.';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get monthJanuary => 'Январь';

  @override
  String get monthFebruary => 'Февраль';

  @override
  String get monthMarch => 'Март';

  @override
  String get monthApril => 'Апрель';

  @override
  String get monthMay => 'Май';

  @override
  String get monthJune => 'Июнь';

  @override
  String get monthJuly => 'Июль';

  @override
  String get monthAugust => 'Август';

  @override
  String get monthSeptember => 'Сентябрь';

  @override
  String get monthOctober => 'Октябрь';

  @override
  String get monthNovember => 'Ноябрь';

  @override
  String get monthDecember => 'Декабрь';

  @override
  String get monthJanuaryShort => 'янв.';

  @override
  String get monthFebruaryShort => 'февр.';

  @override
  String get monthMarchShort => 'март';

  @override
  String get monthAprilShort => 'апр.';

  @override
  String get monthMayShort => 'май';

  @override
  String get monthJuneShort => 'июнь';

  @override
  String get monthJulyShort => 'июль';

  @override
  String get monthAugustShort => 'авг.';

  @override
  String get monthSeptemberShort => 'сент.';

  @override
  String get monthOctoberShort => 'окт.';

  @override
  String get monthNovemberShort => 'нояб.';

  @override
  String get monthDecemberShort => 'дек.';

  @override
  String get weekdayMonShort => 'пн';

  @override
  String get weekdayTueShort => 'вт';

  @override
  String get weekdayWedShort => 'ср';

  @override
  String get weekdayThuShort => 'чт';

  @override
  String get weekdayFriShort => 'пт';

  @override
  String get weekdaySatShort => 'сб';

  @override
  String get weekdaySunShort => 'вс';

  @override
  String get accountTitle => 'Мой аккаунт';

  @override
  String get accountUsernameLabel => 'Имя пользователя';

  @override
  String get accountPasswordLabel => 'Пароль';

  @override
  String get accountEmailLabel => 'Эл. почта';

  @override
  String get accountPasswordLeaveBlankHint => 'Оставьте пустым, чтобы сохранить текущий';

  @override
  String get accountUsernameEmptyError => 'Пожалуйста, введите имя пользователя.';

  @override
  String get accountUsernameTooShortError => 'Слишком коротко.';

  @override
  String get accountEmailEmptyError => 'Пожалуйста, введите эл. почту.';

  @override
  String get accountEmailInvalidError => 'Некорректный адрес эл. почты.';

  @override
  String get accountEmailVerified => 'Эл. почта подтверждена';

  @override
  String get accountEmailNotVerified => 'Эл. почта не подтверждена';

  @override
  String get accountSendButton => 'Отправить';

  @override
  String get accountVerificationEmailSent => 'Письмо для подтверждения отправлено.';

  @override
  String get accountVerificationEmailFailed => 'Не удалось отправить письмо для подтверждения.';

  @override
  String get accountMyHabits => 'Мои привычки';

  @override
  String get accountDeleteAccount => 'Удалить аккаунт';

  @override
  String get accountSaving => 'Сохранение...';

  @override
  String get accountSaveChanges => 'Сохранить изменения';

  @override
  String get accountLogOut => 'Выйти';

  @override
  String get accountChangesSaved => 'Изменения сохранены.';

  @override
  String get accountChangesSavedEmailVerificationHint => 'Изменения сохранены. Проверьте входящие, если было отправлено письмо для подтверждения.';

  @override
  String get accountCouldNotSaveChanges => 'Не удалось сохранить изменения. Попробуйте снова.';

  @override
  String get accountDeleteDialogTitle => 'Удалить аккаунт?';

  @override
  String get accountDeleteDialogBody => 'Это навсегда удалит данные вашего аккаунта.';

  @override
  String get accountDeletedSnackbar => 'Аккаунт удалён.';

  @override
  String get accountCouldNotDelete => 'Не удалось удалить аккаунт.';

  @override
  String get accountRequiresRecentLoginError => 'В целях безопасности, пожалуйста, войдите снова и повторите это действие.';

  @override
  String get accountEmailAlreadyInUseError => 'Этот адрес эл. почты уже используется.';

  @override
  String get accountInvalidEmailError => 'Пожалуйста, введите корректный адрес эл. почты.';

  @override
  String get accountWeakPasswordError => 'Пароль должен быть не короче 6 символов.';

  @override
  String get accountWeakPasswordGenericError => 'Этот пароль слишком слабый.';

  @override
  String get accountAuthGenericError => 'Ошибка аутентификации.';

  @override
  String hubVersionLabel(String version) {
    return 'Версия: $version';
  }

  @override
  String get hubProTitle => 'EcoHabit Pro';

  @override
  String get hubProPlanLabel => 'Pro (годовой)';

  @override
  String get hubMenuSettings => 'Настройки';

  @override
  String get hubMenuAnalytics => 'Аналитика';

  @override
  String get hubMenuJournal => 'Журнал';

  @override
  String get hubMenuAccount => 'Аккаунт';

  @override
  String get hubMenuBackup => 'Резервное копирование';

  @override
  String get proPlanTitle => 'EcoHabit Pro';

  @override
  String get proPlanDefaultLabel => 'Pro (годовой)';

  @override
  String get proPlanSubscribedPrefix => 'Вы подписаны на';

  @override
  String get proPlanUpgradePrefix => 'Перейти на';

  @override
  String get proPlanFreeHeader => 'БЕСПЛАТНО';

  @override
  String get proPlanProHeader => 'PRO';

  @override
  String get proFeatureUnlimitedHabits => 'Неограниченные привычки';

  @override
  String get proFeatureRoutineAi => 'ИИ для рутин';

  @override
  String get proFeatureAnalytics => 'Аналитика';

  @override
  String get proFeatureGoalSetting => 'Постановка целей';

  @override
  String get proFeatureJournaling => 'Ведение журнала';

  @override
  String get proFeatureColorPicker => 'Выбор цвета';

  @override
  String get proFeatureBackupHabits => 'Резервное копирование привычек';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsThemeTitle => 'Тема';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsAccentColorTitle => 'Акцентный цвет';

  @override
  String get settingsStartWeekOnTitle => 'Начинать неделю с';

  @override
  String get settingsStartWeekSaturday => 'Субботы';

  @override
  String get settingsStartWeekSunday => 'Воскресенья';

  @override
  String get settingsStartWeekMonday => 'Понедельника';

  @override
  String get settingsHabitTabsOrderTitle => 'Порядок вкладок привычек';

  @override
  String get settingsHabitTabsOrderHint => 'Нажмите и удерживайте элемент, чтобы изменить порядок';

  @override
  String get analyticsTitle => 'Аналитика';

  @override
  String get analyticsSignInPrompt => 'Пожалуйста, войдите, чтобы просматривать аналитику.';

  @override
  String get analyticsNoHabitsYet => 'Пока нет привычек';

  @override
  String get analyticsHabitFallbackTitle => 'Привычка';

  @override
  String get analyticsAllHabitsTab => 'Все привычки';

  @override
  String get analyticsAverageScore => 'Средний балл';

  @override
  String get analyticsHabitsCompletedTitle => 'Привычек выполнено';

  @override
  String get analyticsTotalCompletedHabitsSubtitle => 'Всего выполненных привычек';

  @override
  String get analyticsHabitHeatmapTitle => 'Тепловая карта привычек';

  @override
  String get analyticsStreakTitle => 'Серия';

  @override
  String get analyticsBestStreak => 'Лучшая серия';

  @override
  String get analyticsCurrentStreak => 'Текущая серия';

  @override
  String get analyticsWeeklyCompletionsTitle => 'Выполнения за неделю';

  @override
  String get analyticsScoreTitle => 'Баллы';

  @override
  String get analyticsNoData => 'Нет данных';

  @override
  String get analyticsThisWeek => 'На этой неделе';

  @override
  String get analyticsThisMonth => 'В этом месяце';

  @override
  String get weekdayShortMon => 'пн';

  @override
  String get weekdayShortTue => 'вт';

  @override
  String get weekdayShortWed => 'ср';

  @override
  String get weekdayShortThu => 'чт';

  @override
  String get weekdayShortFri => 'пт';

  @override
  String get weekdayShortSat => 'сб';

  @override
  String get weekdayShortSun => 'вс';

  @override
  String get weekdayVeryShortMon => 'П';

  @override
  String get weekdayVeryShortTue => 'В';

  @override
  String get weekdayVeryShortWed => 'С';

  @override
  String get weekdayVeryShortThu => 'Ч';

  @override
  String get weekdayVeryShortFri => 'П';

  @override
  String get weekdayVeryShortSat => 'С';

  @override
  String get weekdayVeryShortSun => 'В';

  @override
  String get monthShortJan => 'янв.';

  @override
  String get monthShortFeb => 'февр.';

  @override
  String get monthShortMar => 'март';

  @override
  String get monthShortApr => 'апр.';

  @override
  String get monthShortMay => 'май';

  @override
  String get monthShortJun => 'июнь';

  @override
  String get monthShortJul => 'июль';

  @override
  String get monthShortAug => 'авг.';

  @override
  String get monthShortSep => 'сент.';

  @override
  String get monthShortOct => 'окт.';

  @override
  String get monthShortNov => 'нояб.';

  @override
  String get monthShortDec => 'дек.';
}
