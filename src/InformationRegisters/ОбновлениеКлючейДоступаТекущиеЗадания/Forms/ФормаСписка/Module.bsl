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
	
	ТолькоПросмотр = Истина;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ВключитьВозможностьРедактирования(Команда)
	
	ТолькоПросмотр = Ложь;
	
КонецПроцедуры

&НаКлиенте
Процедура ОтменитьФоновоеЗадание(Команда)
	
	Если Элементы.Список.ТекущиеДанные = Неопределено Тогда
		ПоказатьПредупреждение(, НСтр("ru = 'Запись не выделена.'"));
		Возврат;
	КонецЕсли;
	
	ТекстРезультата = "";
	ОтменитьФоновоеЗаданиеНаСервере(Элементы.Список.ТекущиеДанные.ИдентификаторПотока, ТекстРезультата);
	
	ПоказатьПредупреждение(, ТекстРезультата);
	
КонецПроцедуры


#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Процедура ОтменитьФоновоеЗаданиеНаСервере(ИдентификаторЗадания, ТекстРезультата)
	
	ФоновоеЗадание = ФоновыеЗадания.НайтиПоУникальномуИдентификатору(ИдентификаторЗадания);
	
	Если ФоновоеЗадание = Неопределено Тогда
		ТекстРезультата = НСтр("ru = 'Не удалость найти фоновое задание по идентификатору.'");
		Возврат;
	КонецЕсли;
	
	Попытка
		ФоновоеЗадание.Отменить();
		ТекстРезультата = НСтр("ru = 'Фоновое задание отменено.'");
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		ТекстРезультата = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось отменить фоновое задание по причине:
			           |%1'"), КраткоеПредставлениеОшибки(ИнформацияОбОшибке));
	КонецПопытки;
	
КонецПроцедуры

#КонецОбласти


