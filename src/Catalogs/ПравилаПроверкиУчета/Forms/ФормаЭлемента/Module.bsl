///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если НЕ ЗначениеЗаполнено(Объект.Ссылка) Тогда
		ВызватьИсключение НСтр("ru = 'Интерактивное создание запрещено.'");
	КонецЕсли;
	
	ОбновлениеИнформационнойБазы.ПроверитьОбъектОбработан(Объект, ЭтотОбъект);
	Элементы.ПредставлениеИндивидуальногоРасписания.Доступность = Не ТолькоПросмотр;
	Элементы.ПредставлениеОбщегоРасписания.Доступность          = Не ТолькоПросмотр;
	
	МетаданныеТекущейПроверки = МетаданныеПроверки(Объект.Идентификатор);
	УстановитьДоступностьПоляВажности(ЭтотОбъект, МетаданныеТекущейПроверки);
	УстановитьПутьДоПроцедурыОбработчика(ЭтотОбъект, МетаданныеТекущейПроверки);
	
	РазрешеноНастраиватьПравилаПроверкиУчета = ПравоДоступа("Изменение", Метаданные.Справочники.ПравилаПроверкиУчета);
	Элементы.ФормаВыполнитьПроверку.Видимость              = РазрешеноНастраиватьПравилаПроверкиУчета;
	Элементы.ФормаУстановитьСтандартныеНастройки.Видимость = РазрешеноНастраиватьПравилаПроверкиУчета;
	
	УстановитьНачальныеНастройкиРасписания();
	ЭтоАдминистраторСистемы = Пользователи.ЭтоПолноправныйПользователь(, Истина);
	Если Не ОбщегоНазначения.РазделениеВключено() Или ЭтоАдминистраторСистемы Тогда
		СформироватьРасписания();
	ИначеЕсли ОбщегоНазначения.РазделениеВключено() И Не ЭтоАдминистраторСистемы Тогда
		Элементы.ГруппаРасписание.Видимость = Ложь;
	КонецЕсли;
		
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиент.НачатьОбновлениеКоманд(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	Если Не ЗначениеЗаполнено(ТекущийОбъект.Код) Тогда
		ТекущийОбъект.УстановитьНовыйКод();
	КонецЕсли;
	
	Если ЗначениеЗаполнено(АдресИндивидуальногоРасписания) Тогда
		ТекущийОбъект.РасписаниеВыполненияПроверки = ПолучитьИзВременногоХранилища(АдресИндивидуальногоРасписания);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПредставлениеИндивидуальногоРасписанияОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ДанныеХранилища = ПолучитьИзВременногоХранилища(НавигационнаяСсылкаФорматированнойСтроки);
	Если ДанныеХранилища = "ДобавитьЗадание" Тогда
		ДиалогРасписания    = Новый ДиалогРасписанияРегламентногоЗадания(Новый РасписаниеРегламентногоЗадания);
		ОповещениеИзменения = Новый ОписаниеОповещения("ДобавитьЗаданиеНаКлиентеЗавершение", ЭтотОбъект);
		ДиалогРасписания.Показать(ОповещениеИзменения);
	Иначе
		ДиалогРасписания    = Новый ДиалогРасписанияРегламентногоЗадания(ДанныеХранилища);
		ОповещениеИзменения = Новый ОписаниеОповещения("ИзменитьЗаданиеНаКлиентеЗавершение", ЭтотОбъект);
		ДиалогРасписания.Показать(ОповещениеИзменения);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполняетсяВФонеПоРасписаниюПриИзменении(Элемент)
	
	Если ВыполняетсяВФонеПоРасписанию Тогда
		УстановитьНастройкиРасписанияНаСервере();
	Иначе
		СкрытьНастройкиРасписанияНаСервере();
	КонецЕсли;
	
	Модифицированность = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура СелекторРасписанияПриИзменении(Элемент)
	
	УстановитьНастройкиРасписанияНаСервере();
	Модифицированность = Истина;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ВыполнитьПроверку(Команда)
	
	Если Не Записать() Тогда
		Возврат;
	КонецЕсли;	
	
	Если Не Объект.Использование Тогда
		ОповещениеОЗавершении = Новый ОписаниеОповещения("ВыполнитьПроверкуПослеВопроса", ЭтотОбъект);
		ПоказатьВопрос(ОповещениеОЗавершении, НСтр("ru = 'Проверка отключена. Все равно выполнить?'"), РежимДиалогаВопрос.ДаНет);
		Возврат;
	КонецЕсли;	
	
	ВыполнитьПроверкуПослеВопроса(КодВозвратаДиалога.Да, Неопределено);
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьСтандартныеНастройки(Команда)
	
	ТекстВопроса = НСтр("ru = 'Установить стандартные настройки?'");
	Обработчик = Новый ОписаниеОповещения("УстановитьСтандартныеНастройкиНаКлиенте", ЭтотОбъект);
	ПоказатьВопрос(Обработчик, ТекстВопроса, РежимДиалогаВопрос.ДаНет);
	
КонецПроцедуры

&НаКлиенте
Процедура ОчиститьРезультатыПроверки(Команда)
	ОчиститьРезультатыПроверкиНаСервере();
	Сообщение = НСтр("ru = 'Результаты предыдущих проверок успешно очищены.'");
	ОбщегоНазначенияКлиент.СообщитьПользователю(Сообщение);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция ВыполнитьПроверкуНаСервере()
	
	Если ДлительнаяОперация <> Неопределено Тогда
		ДлительныеОперации.ОтменитьВыполнениеЗадания(ДлительнаяОперация.ИдентификаторЗадания);
	КонецЕсли;
	
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Выполнение проверки ведения учета ""%1""'"), Объект.Наименование);
	
	Проверки = Новый Массив;
	Проверки.Добавить(Объект.Ссылка);
	Возврат ДлительныеОперации.ВыполнитьПроцедуру(ПараметрыВыполнения, "КонтрольВеденияУчетаСлужебный.ВыполнитьПроверки", Проверки);
	
КонецФункции

&НаКлиенте
Процедура ВыполнитьПроверкуПослеВопроса(РезультатВопроса, ДополнительныеПараметры) Экспорт
	
	Если РезультатВопроса <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;	
	
	ДлительнаяОперация = ВыполнитьПроверкуНаСервере();
	
	ОповещениеОЗавершении = Новый ОписаниеОповещения("ВыполнитьПроверкуЗавершение", ЭтотОбъект);
	ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
	ПараметрыОжидания.ТекстСообщения = НСтр("ru = 'Выполняется проверка. Это может занять некоторое время.'");
	ДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, ОповещениеОЗавершении, ПараметрыОжидания);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьПроверкуЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Результат.Статус = "Ошибка" Тогда
		ВызватьИсключение Результат.КраткоеПредставлениеОшибки;
	ИначеЕсли Результат.Статус = "Выполнено" Тогда
		ПоказатьОповещениеПользователя(НСтр("ru = 'Проверка выполнена'"),,
			НСтр("ru = 'Проверка ведения учета завершена успешно.'"));
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура СформироватьРасписания()
	
	СформироватьСтрокуСОбщимРасписанием();
	СформироватьСтрокуСИндивидуальнымРасписанием();
	
КонецПроцедуры

&НаСервере
Процедура СформироватьСтрокуСИндивидуальнымРасписанием()
	
	ИдентификаторРегламентногоЗадания = Объект.ИдентификаторРегламентногоЗадания;
	ОтдельноеРегламентноеЗадание      = Неопределено;
	ОтдельноеРасписаниеПредставление  = "";
	
	Если ЗначениеЗаполнено(ИдентификаторРегламентногоЗадания) Тогда
		ОтдельноеРегламентноеЗадание = РегламентныеЗаданияСервер.Задание(ИдентификаторРегламентногоЗадания);
		Если ОтдельноеРегламентноеЗадание <> Неопределено Тогда
			ОтдельноеРасписаниеПредставление = Строка(ОтдельноеРегламентноеЗадание.Расписание) + ". ";
		КонецЕсли;
	КонецЕсли;
	
	Если Не ОбщегоНазначения.РазделениеВключено() Тогда
		
		Если ОтдельноеРегламентноеЗадание = Неопределено Тогда
			Элементы.ПредставлениеИндивидуальногоРасписания.Заголовок = 
				Новый ФорматированнаяСтрока(НСтр("ru = 'Настроить расписание'"), , , , ПоместитьВоВременноеХранилище("ДобавитьЗадание", УникальныйИдентификатор));
		Иначе
			Элементы.ПредставлениеИндивидуальногоРасписания.Заголовок = 
				Новый ФорматированнаяСтрока(ОтдельноеРасписаниеПредставление, , , , ПоместитьВоВременноеХранилище(ОтдельноеРегламентноеЗадание.Расписание, УникальныйИдентификатор));
		КонецЕсли;
		
	Иначе
		
		Если ОтдельноеРегламентноеЗадание = Неопределено Тогда
			Элементы.ПредставлениеИндивидуальногоРасписания.Заголовок = 
				Новый ФорматированнаяСтрока(ОтдельноеРасписаниеПредставление + ". ", , ЦветаСтиля.ГиперссылкаЦвет);
		Иначе
			Элементы.ПредставлениеИндивидуальногоРасписания.Заголовок = 
				Новый ФорматированнаяСтрока(ОтдельноеРасписаниеПредставление, , ЦветаСтиля.ГиперссылкаЦвет);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура СформироватьСтрокуСОбщимРасписанием()
	
	ОбщееРегламентноеЗадание = РегламентныеЗаданияСервер.Задание(Метаданные.РегламентныеЗадания.ПроверкаВеденияУчета);
	Если ОбщееРегламентноеЗадание <> Неопределено Тогда
		Если Не ОбщегоНазначения.РазделениеВключено() Тогда
			ОбщееРасписаниеПредставление = Строка(ОбщееРегламентноеЗадание.Расписание);
		Иначе
			Если Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
				ОбщееРасписаниеПредставление = Строка(ОбщееРегламентноеЗадание.Шаблон.Расписание.Получить());
			КонецЕсли;
		КонецЕсли;
	Иначе
		ОбщееРасписаниеПредставление = НСтр("ru = 'Не найдено общее регламентное задание'");
	КонецЕсли;
	
	Элементы.ПредставлениеОбщегоРасписания.Заголовок = 
		Новый ФорматированнаяСтрока(ОбщееРасписаниеПредставление, , ЦветаСтиля.ГиперссылкаЦвет);
	
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьЗаданиеНаКлиентеЗавершение(Расписание, ДополнительныеПараметры) Экспорт
	ИзменитьЗаданиеНаСервереЗавершение(Расписание, ДополнительныеПараметры);
КонецПроцедуры

&НаСервере
Процедура ИзменитьЗаданиеНаСервереЗавершение(Расписание, ДополнительныеПараметры)
	
	Если Расписание = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	РегламентноеЗадание = РегламентныеЗаданияСервер.Задание(Объект.ИдентификаторРегламентногоЗадания);
	Если РегламентноеЗадание = Неопределено Тогда
		ДобавитьЗаданиеНаСервереЗавершение(Расписание, ДополнительныеПараметры);
	Иначе
		
		РегламентныеЗаданияСервер.ИзменитьЗадание(Объект.ИдентификаторРегламентногоЗадания, Новый Структура("Расписание", Расписание));
		Элементы.ПредставлениеИндивидуальногоРасписания.Заголовок = 
			Новый ФорматированнаяСтрока(Строка(Расписание), , , , ПоместитьВоВременноеХранилище(Расписание, УникальныйИдентификатор));
		
		АдресИндивидуальногоРасписания = ПоместитьВоВременноеХранилище(Новый ХранилищеЗначения(ОбщегоНазначенияКлиентСервер.РасписаниеВСтруктуру(Расписание)), УникальныйИдентификатор);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьЗаданиеНаКлиентеЗавершение(Расписание, ДополнительныеПараметры) Экспорт
	ДобавитьЗаданиеНаСервереЗавершение(Расписание, ДополнительныеПараметры);
КонецПроцедуры

&НаСервере
Процедура ДобавитьЗаданиеНаСервереЗавершение(Расписание, ДополнительныеПараметры)
		
	Если Расписание = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыЗадания = Новый Структура;
	ПараметрыЗадания.Вставить("Расписание",    Расписание);
	ПараметрыЗадания.Вставить("Использование", Истина);
	ПараметрыЗадания.Вставить("Метаданные",    Метаданные.РегламентныеЗадания.ПроверкаВеденияУчета);
	
	РегламентноеЗадание = РегламентныеЗаданияСервер.ДобавитьЗадание(ПараметрыЗадания);
	
	Объект.ИдентификаторРегламентногоЗадания = Строка(РегламентноеЗадание.УникальныйИдентификатор);
	
	ПараметрыЗадания = Новый Структура;
	
	МассивПараметров = Новый Массив;
	МассивПараметров.Добавить(Строка(РегламентноеЗадание.УникальныйИдентификатор));
	
	ПараметрыЗадания.Вставить("Параметры", МассивПараметров);
	РегламентныеЗаданияСервер.ИзменитьЗадание(РегламентноеЗадание.УникальныйИдентификатор, ПараметрыЗадания);
	
	Элементы.ПредставлениеИндивидуальногоРасписания.Заголовок =
		Новый ФорматированнаяСтрока(Строка(Расписание), , , , ПоместитьВоВременноеХранилище(Расписание, УникальныйИдентификатор));
		
	АдресИндивидуальногоРасписания = ПоместитьВоВременноеХранилище(Новый ХранилищеЗначения(ОбщегоНазначенияКлиентСервер.РасписаниеВСтруктуру(Расписание)), УникальныйИдентификатор);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция МетаданныеПроверки(Идентификатор)
	
	СтруктураПроверки = Новый Структура;
	Проверки          = КонтрольВеденияУчетаСлужебныйПовтИсп.ПроверкиВеденияУчета().Проверки;
	СтрокаПроверки    = Проверки.Найти(Идентификатор, "Идентификатор");
	
	Если СтрокаПроверки = Неопределено Тогда
		Возврат Неопределено;
	Иначе
		КолонкиПроверок = Проверки.Колонки;
		Для Каждого ТекущаяКолонка Из КолонкиПроверок Цикл
			СтруктураПроверки.Вставить(ТекущаяКолонка.Имя, СтрокаПроверки[ТекущаяКолонка.Имя]);
		КонецЦикла;
	КонецЕсли;
	
	Возврат СтруктураПроверки;
	
КонецФункции

&НаСервереБезКонтекста
Процедура УстановитьДоступностьПоляВажности(Форма, МетаданныеТекущейПроверки)
	Форма.Элементы.ВажностьПроблемы.Доступность = Не (МетаданныеТекущейПроверки <> Неопределено И МетаданныеТекущейПроверки.ЗапрещеноИзменениеВажности);
КонецПроцедуры

&НаСервереБезКонтекста
Процедура УстановитьПутьДоПроцедурыОбработчика(Форма, МетаданныеТекущейПроверки)
	Форма.ПутьДоПроцедурыОбработчика = ?(МетаданныеТекущейПроверки = Неопределено, НСтр("ru = 'Не задан обработчик'"), МетаданныеТекущейПроверки.ОбработчикПроверки);
КонецПроцедуры

&НаСервере
Процедура ОчиститьРезультатыПроверкиНаСервере()
	
	НаборЗаписей = РегистрыСведений.РезультатыПроверкиУчета.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.ПравилоПроверки.Установить(Объект.Ссылка);
	НаборЗаписей.Записать(Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьСтандартныеНастройкиНаКлиенте(Ответ, ПараметрыВыполнения) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьСтандартныеНастройкиНаСервере();
	Модифицированность = Истина;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьСтандартныеНастройкиНаСервере()
	
	МетаданныеТекущейПроверки = МетаданныеПроверки(Объект.Идентификатор);
	Если МетаданныеТекущейПроверки = Неопределено Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Рассинхронизация проверок учета. Проверка с идентификатором ""%1"" не найдена в метаданных.'"), Объект.Идентификатор);
	КонецЕсли;
		
	ЗаполнитьЗначенияСвойств(Объект, МетаданныеТекущейПроверки, , "Идентификатор");
	Объект.ПроверкаВеденияУчетаИзменена = Ложь;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьНастройкиРасписанияНаСервере()
	
	Если СелекторРасписания = 0 Тогда
		
		Если Объект.СпособВыполнения = Перечисления.СпособыВыполненияПроверки.ПоОбщемуРасписанию Тогда
			
			СелекторРасписания = 1;
			
			Элементы.СелекторРасписания.Доступность                     = Истина;
			Элементы.ПредставлениеИндивидуальногоРасписания.Доступность = Ложь;
			Элементы.ПредставлениеОбщегоРасписания.Доступность          = Истина;
			
		ИначеЕсли Объект.СпособВыполнения = Перечисления.СпособыВыполненияПроверки.ПоОтдельномуРасписанию Тогда
			
			СелекторРасписания = 2;
			
			Элементы.СелекторРасписания.Доступность                     = Истина;
			Элементы.ПредставлениеИндивидуальногоРасписания.Доступность = Истина;
			Элементы.ПредставлениеОбщегоРасписания.Доступность          = Ложь;
			
		КонецЕсли;
		
	ИначеЕсли СелекторРасписания = 1 Тогда
		
		Объект.СпособВыполнения = Перечисления.СпособыВыполненияПроверки.ПоОбщемуРасписанию;
		Элементы.СелекторРасписания.Доступность                     = Истина;
		Элементы.ПредставлениеИндивидуальногоРасписания.Доступность = Ложь;
		Элементы.ПредставлениеОбщегоРасписания.Доступность          = Истина;
		
	ИначеЕсли СелекторРасписания = 2 Тогда
		
		Объект.СпособВыполнения = Перечисления.СпособыВыполненияПроверки.ПоОтдельномуРасписанию;
		Элементы.СелекторРасписания.Доступность                     = Истина;
		Элементы.ПредставлениеИндивидуальногоРасписания.Доступность = Истина;
		Элементы.ПредставлениеОбщегоРасписания.Доступность          = Ложь;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура СкрытьНастройкиРасписанияНаСервере()
	
	Объект.СпособВыполнения = Перечисления.СпособыВыполненияПроверки.Вручную;
	Элементы.СелекторРасписания.Доступность                     = Ложь;
	Элементы.ПредставлениеИндивидуальногоРасписания.Доступность = Ложь;
	Элементы.ПредставлениеОбщегоРасписания.Доступность          = Ложь;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьНачальныеНастройкиРасписания()
	
	Если Объект.СпособВыполнения = Перечисления.СпособыВыполненияПроверки.ПоОбщемуРасписанию Тогда
		
		ВыполняетсяВФонеПоРасписанию = Истина;
		СелекторРасписания           = 1;
		
		Элементы.СелекторРасписания.Доступность                     = Истина;
		Элементы.ПредставлениеИндивидуальногоРасписания.Доступность = Ложь;
		Элементы.ПредставлениеОбщегоРасписания.Доступность          = Истина;
		
	ИначеЕсли Объект.СпособВыполнения = Перечисления.СпособыВыполненияПроверки.ПоОтдельномуРасписанию Тогда
		
		ВыполняетсяВФонеПоРасписанию = Истина;
		СелекторРасписания           = 2;
		
		Элементы.СелекторРасписания.Доступность                     = Истина;
		Элементы.ПредставлениеИндивидуальногоРасписания.Доступность = Истина;
		Элементы.ПредставлениеОбщегоРасписания.Доступность          = Ложь;
		
	Иначе
		
		ВыполняетсяВФонеПоРасписанию = Ложь;
		СелекторРасписания           = 1;
		
		Элементы.СелекторРасписания.Доступность                     = Ложь;
		Элементы.ПредставлениеИндивидуальногоРасписания.Доступность = Ложь;
		Элементы.ПредставлениеОбщегоРасписания.Доступность          = Ложь
		
	КонецЕсли;
	
КонецПроцедуры

// СтандартныеПодсистемы.ПодключаемыеКоманды
&НаКлиенте
Процедура Подключаемый_ВыполнитьКоманду(Команда)
	ПодключаемыеКомандыКлиент.НачатьВыполнениеКоманды(ЭтотОбъект, Команда, Объект);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ПродолжитьВыполнениеКомандыНаСервере(ПараметрыВыполнения, ДополнительныеПараметры) Экспорт
	ВыполнитьКомандуНаСервере(ПараметрыВыполнения);
КонецПроцедуры

&НаСервере
Процедура ВыполнитьКомандуНаСервере(ПараметрыВыполнения)
	ПодключаемыеКоманды.ВыполнитьКоманду(ЭтотОбъект, ПараметрыВыполнения, Объект);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ОбновитьКоманды()
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
КонецПроцедуры

// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

#КонецОбласти