#Область о // Стандартные процедуры и функции:

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
    
    Если Не ЗначениеЗаполнено(ЭтотОбъект.ДатаУвольнения) Тогда
		ЭтотОбъект.ДатаУвольнения = ЭтотОбъект.Дата;
	КонецЕсли;
	
    Если Не ЗначениеЗаполнено(ЭтотОбъект.ДатаПриказа) Тогда
		ЭтотОбъект.ДатаПриказа = ЭтотОбъект.ДатаУвольнения;
	КонецЕсли;
	
	// +++ Чесноков М.С. 2021-09-22 F1-121
	фуКадровыйУчетСервер.УдалениеСкановДокументаПередЗаписью(ЭтотОбъект);
	// --- Чесноков М.С. 2021-09-22 F1-121
	
КонецПроцедуры

Процедура ПриКопировании(ОбъектКопирования)
	
	// +++ Чесноков М.С. 2021-09-22 F1-121
	ЭтотОбъект.Сотрудник = Справочники.фуСотрудники.ПустаяСсылка();
	ЭтотОбъект.СканыДокументовКадры.Очистить();
	// --- Чесноков М.С. 2021-09-22 F1-121

КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	
	Если ЗначениеЗаполнено(ДанныеЗаполнения) Тогда
		Если ДанныеЗаполнения.Свойство("Сотрудник") Тогда
			ЭтотОбъект.Сотрудник = ДанныеЗаполнения.Сотрудник;
		КонецЕсли; 
	КонецЕсли; 

КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)
	
	ЗаписьДвижений_фуКадроваяИсторияСотрудников(Отказ,Режим);
    
КонецПроцедуры

#КонецОбласти

#Область о // Запись движений:

Процедура ЗаписьДвижений_фуКадроваяИсторияСотрудников(Отказ,Режим)
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
		
	КадровыеДанныеСотрудника = фуКадровыйУчетСервер.ПолучитьКадровыеДанныеСотрудника(ЭтотОбъект.Сотрудник,НачалоДня(ЭтотОбъект.ДатаУвольнения)-1);
	
	Движение = Движения.фуКадроваяИсторияСотрудников.Добавить();
	//
	ЗаполнитьЗначенияСвойств(Движение,КадровыеДанныеСотрудника);
	ЗаполнитьЗначенияСвойств(Движение,ЭтотОбъект);
	//
	Движение.Период = ЭтотОбъект.ДатаУвольнения;
	Движение.ВидСобытия = Перечисления.фуВидыКадровыхСобытий.Увольнение;
    
    Движения.фуКадроваяИсторияСотрудников.Записать(Истина);
	
КонецПроцедуры

#КонецОбласти
