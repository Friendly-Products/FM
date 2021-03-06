
#Область о // Стандартные процедуры и функции:

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// +++ Чесноков М.С. 2021-09-22 F1-121
	Если Параметры.Свойство("КадровыйДокумент") Тогда
		
		Если Не ЗначениеЗаполнено(Объект.СканДата) Тогда
			Объект.СканДата = ТекущаяДата();
		КонецЕсли; 
		Если Параметры.Свойство("КадровыйДокумент") Тогда
			Объект.Источник = Параметры.КадровыйДокумент;
		КонецЕсли;
		
	КонецЕсли; 
	
	// Если вдруг сотрудника поменяли:
	Если Параметры.Свойство("Сотрудник") Тогда
		
		Если ЗначениеЗаполнено(Параметры.Сотрудник) Тогда
			Объект.Сотрудник = Параметры.Сотрудник;	
		КонецЕсли;		
		
	КонецЕсли; 
	
	Если ЗначениеЗаполнено(Объект.Ссылка) Тогда
		мСканДокумента = ПоместитьВоВременноеХранилище(Объект.Ссылка.Файл.Получить());	
	КонецЕсли; 
	
	мНоваяЗапись = Не ЗначениеЗаполнено(Объект.Ссылка);	
	// --- Чесноков М.С. 2021-09-22 F1-121
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	
	// +++ Чесноков М.С. 2021-09-22 F1-121
	Если мНоваяЗапись Тогда
		Оповестить("ЗакрытиеФормыПриДобавленииНовогоСканаДокумента",Объект.Ссылка);	
	КонецЕсли; 
	// --- Чесноков М.С. 2021-09-22 F1-121
	
КонецПроцедуры

#КонецОбласти 

#Область о // Загрузка скана документа:

// +++ Чесноков М.С. 2021-09-22 F1-121
&НаКлиенте
Процедура ЗагрузитьСканДокумента(Команда)
	
	// Из файла с клиента
    ПараметрыДиалога = Новый Структура;
    ПараметрыДиалога.Вставить("Заголовок", НСтр("ru = 'Укажите файл со сканом.'"));
    ПараметрыДиалога.Вставить("Фильтр", НСтр("ru = 'Все файлы (*.*)'") + "|*.*");

    Оповещение = Новый ОписаниеОповещения("ЗагрузитьСканДокументаЗавершение", ЭтотОбъект);
    ОбменДаннымиКлиент.ВыбратьИПередатьФайлНаСервер(Оповещение, ПараметрыДиалога, УникальныйИдентификатор);

КонецПроцедуры
// --- Чесноков М.С. 2021-09-22 F1-121

// +++ Чесноков М.С. 2021-09-22 F1-121
&НаКлиенте
Процедура ЗагрузитьСканДокументаЗавершение(Знач РезультатПомещенияФайлов, Знач ДополнительныеПараметры) Экспорт
	
	АдресПомещенногоФайла = РезультатПомещенияФайлов.Хранение;
	ТекстОшибки           = РезультатПомещенияФайлов.ОписаниеОшибки;
	
	Если ПустаяСтрока(ТекстОшибки) И ПустаяСтрока(АдресПомещенногоФайла) Тогда
		ТекстОшибки = НСтр("ru = 'Ошибка передачи файла настроек синхронизации данных на сервер!'");
	КонецЕсли;
	
	Если Не ПустаяСтрока(ТекстОшибки) Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю(ТекстОшибки);
		Возврат;
	КонецЕсли;
		
	// Успешно передали файл, загружаем на сервере.
	УстановитьКартинкуНаСервере(АдресПомещенногоФайла);
	мСканДокумента = ПолучитьНавигационнуюСсылку(Объект.Ссылка, "Файл");
	
КонецПроцедуры
// --- Чесноков М.С. 2021-09-22 F1-121

// +++ Чесноков М.С. 2021-09-22 F1-121
&НаСервере
Процедура УстановитьКартинкуНаСервере(АдресВременногоХранилища)
	
	ЭлементСправочника = РеквизитФормыВЗначение("Объект");
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресВременногоХранилища);
	ЭлементСправочника.Файл = Новый ХранилищеЗначения(ДвоичныеДанные, Новый СжатиеДанных());
	ЭлементСправочника.Записать();
	
	УдалитьИзВременногоХранилища(АдресВременногоХранилища);
	ЗначениеВРеквизитФормы(ЭлементСправочника, "Объект");     

КонецПроцедуры
// --- Чесноков М.С. 2021-09-22 F1-121

#КонецОбласти 
