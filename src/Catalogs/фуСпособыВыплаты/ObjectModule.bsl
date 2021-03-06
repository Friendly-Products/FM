
Процедура ПроверкаНаСозданныйРанееСпособВыплаты(Отказ)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	фмСпособыВыплаты.Ссылка КАК Ссылка,
		|	фмСпособыВыплаты.Владелец КАК Владелец,
		|	фмСпособыВыплаты.ВидВыплаты КАК ВидВыплаты
		|ИЗ
		|	Справочник.фмСпособыВыплаты КАК фмСпособыВыплаты
		|ГДЕ
		|	фмСпособыВыплаты.Владелец = &Владелец
		|	И фмСпособыВыплаты.ВидВыплаты = &ВидВыплаты";
	
	Запрос.УстановитьПараметр("ВидВыплаты", ЭтотОбъект.ВидВыплаты);
	Запрос.УстановитьПараметр("Владелец", ЭтотОбъект.Владелец);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Если ВыборкаДетальныеЗаписи.Количество() > 0 Тогда
		Отказ = Истина;
		фуОбщийКлиентСервер.СообщитьПользователю("Внимание! Данный способ выплаты уже был введен ранее.");
	КонецЕсли;

КонецПроцедуры

Процедура ПередЗаписью(Отказ)
	
	Если ЭтоНовый() Тогда
		
		ПроверкаНаСозданныйРанееСпособВыплаты(Отказ);
		
	КонецЕсли;
	
КонецПроцедуры
