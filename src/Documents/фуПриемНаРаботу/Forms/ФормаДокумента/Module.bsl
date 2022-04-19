
#Область о // Стандартные процедуры и функции:

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ПриОткрытииНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура ПриОткрытииНаСервере()
	
	фуОбщийСервер.УстановитьДоступоностьРеквизитовНаФорме(Элементы,Объект.Ссылка);    
	
КонецПроцедуры    

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	// +++ Чесноков М.С. 2021-09-22 F1-121
	Если ИмяСобытия = "ЗакрытиеФормыПриДобавленииНовогоСканаДокумента"  Тогда
		
		Если ЗначениеЗаполнено(Параметр) Тогда
			ДобавитьСтрокуВТЧНаСервере(Параметр);
		КонецЕсли; 
		
	КонецЕсли; 
	// --- Чесноков М.С. 2021-09-22 F1-121
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьСтрокуВТЧНаСервере(Параметр)
	
	НоваяСтрока =  Объект.СканыДокументовКадры.Добавить();
	НоваяСтрока.СканДокумента = Параметр;
	
КонецПроцедуры

&НаКлиенте
Процедура СканыДокументовКадрыВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	// +++ Чесноков М.С. 2021-09-22 F1-121
	Если ЗначениеЗаполнено(Элемент.ТекущиеДанные.СканДокумента) Тогда
		
		фуКадровыйУчетКлиент.ОткрытьФорму_фуСканыДокументовКадры(Объект,Элемент.ТекущиеДанные.СканДокумента);
		
	КонецЕсли;                            
	// --- Чесноков М.С. 2021-09-22 F1-121
	
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьСканДокумента(Команда)
	
	// +++ Чесноков М.С. 2021-09-22 F1-121
	фуКадровыйУчетКлиент.ОткрытьФорму_фуСканыДокументовКадры(Объект,,);
	// --- Чесноков М.С. 2021-09-22 F1-121
	
КонецПроцедуры

#КонецОбласти 


