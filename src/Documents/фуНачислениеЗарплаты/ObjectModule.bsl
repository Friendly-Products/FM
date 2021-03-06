#Область о // Стандартные процедуры и функции:

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	ЗаполнитьРеквизитыОбъекта();
	
КонецПроцедуры

Процедура ЗаполнитьРеквизитыОбъекта() 

	ЗаполнитьДополнительныеПоляВТабличнойЧастиНачисления();

КонецПроцедуры

Процедура ЗаполнитьДополнительныеПоляВТабличнойЧастиНачисления() 
	
	// Заполнение доп полей в табличной части начисления:
	Для каждого стрНачисления из ЭтотОбъект.Начисления Цикл
		
		Если Не ЗначениеЗаполнено(стрНачисления.СтатьяЗатрат) Тогда
			стрНачисления.СтатьяЗатрат = стрНачисления.Начисление.СтатьяЗатрат;
		КонецЕсли;
		
		Если Не ЗначениеЗаполнено(стрНачисления.Валюта) Тогда
			стрНачисления.Валюта = стрНачисления.Начисление.Валюта;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры
	          
Процедура ОбработкаПроведения(Отказ, Режим)

	//
	сОсновныеВалюты = фуОперацииСВалютамиКлиентСервер.ПолучитьОсновныеВалютыСервер();
	//
	
	ЗаписьДвижений_фуНачисленияУдержанияПоСотрудникам(Отказ,Режим);
	ЗаписьДвижений_фуДоходыИРасходы(Отказ,Режим,сОсновныеВалюты);
    
КонецПроцедуры

#КонецОбласти

#Область о // Запись движений документа:

Процедура ЗаписьДвижений_фуНачисленияУдержанияПоСотрудникам(Отказ,Режим)
	
	Если Отказ Тогда
		Возврат;                   
	КонецЕсли;

	Движения.фуНачисленияУдержанияПоСотрудникам.Записывать = Истина;
	
	Для Каждого ТекСтрокаОплата Из Начисления Цикл
        
		Если ТекСтрокаОплата.Сумма <> 0 Тогда
			Движение = Движения.фуНачисленияУдержанияПоСотрудникам.ДобавитьПриход();
			ЗаполнитьЗначенияСвойств(Движение,ТекСтрокаОплата);
			Движение.Период = НачалоМесяца(ЭтотОбъект.ПериодНачисления);
			Движение.ВидНачисленияУдержания = ТекСтрокаОплата.Начисление;
			Движение.ВидЗарплаты = ЭтотОбъект.ВидЗарплаты;
	    КонецЕсли; 
        
	КонецЦикла;
	
КонецПроцедуры

Процедура ЗаписьДвижений_фуДоходыИРасходы(Отказ,Режим,сОсновныеВалюты)
	
	Если Отказ Тогда
		Возврат;                   
	КонецЕсли;
	
	Движения.фуДоходыИРасходы.Записывать = Истина;
	
	НачисленияТаблица = ПолучитьНачисленияОбъекта();
	
	Для каждого НачислениеСтрока из НачисленияТаблица Цикл
		
		СуммаДоллары = (-1)*РаботаСКурсамиВалют.ПересчитатьВВалюту(НачислениеСтрока.Сумма,
		                                                           НачислениеСтрока.Валюта,
																   сОсновныеВалюты.Доллар,
																   НачислениеСтрока.Период);  
		
		Движение 				= Движения.фуДоходыИРасходы.Добавить();
		ЗаполнитьЗначенияСвойств(Движение,НачислениеСтрока);
		Движение.Период			= НачалоМесяца(Движение.Период);
		Движение.Сумма 	= СуммаДоллары;
        Движение.ВыплатаИлиНачислениеЗП = Истина;
            
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьНачисленияОбъекта()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	фуНачислениеЗарплатыНачисления.Ссылка.ПериодНачисления КАК Период,
		|	фуНачислениеЗарплатыНачисления.Сотрудник КАК Сотрудник,
		|	фуНачислениеЗарплатыНачисления.СтатьяЗатрат КАК СтатьяЗатрат,
		|	фуНачислениеЗарплатыНачисления.Валюта КАК Валюта,
		|	СУММА(фуНачислениеЗарплатыНачисления.Сумма) КАК Сумма
		|ИЗ
		|	Документ.фуНачислениеЗарплаты.Начисления КАК фуНачислениеЗарплатыНачисления
		|ГДЕ
		|	фуНачислениеЗарплатыНачисления.Ссылка = &ДокументСсылка
		|	И фуНачислениеЗарплатыНачисления.Сумма <> 0
		|
		|СГРУППИРОВАТЬ ПО
		|	фуНачислениеЗарплатыНачисления.Ссылка.ПериодНачисления,
		|	фуНачислениеЗарплатыНачисления.Сотрудник,
		|	фуНачислениеЗарплатыНачисления.СтатьяЗатрат,
		|	фуНачислениеЗарплатыНачисления.Валюта";
	
	Запрос.УстановитьПараметр("ДокументСсылка",ЭтотОбъект.Ссылка);
	
	Возврат Запрос.Выполнить().Выгрузить();

КонецФункции

#КонецОбласти

#Область о // Расчет заработной платы:

Процедура ПересчетСотрудниковВОбъекте(СписокСотрудников = Неопределено,ПерерасчетСотрудников = Истина) Экспорт

	стрДанныеНачисленияЗарплаты = фуНачислениеЗарплатыСервер.ПолучитьСтрукруруДанныхНачисленияЗарплатыМСК(ЭтотОбъект);
    
    Если ТипЗнч(СписокСотрудников) = Тип("СправочникСсылка.фуСотрудники") Тогда
		стрДанныеНачисленияЗарплаты.СотрудникиМассив.Добавить(СписокСотрудников);
	ИначеЕсли ЗначениеЗаполнено(СписокСотрудников) Тогда 
		Для каждого стрСотрудник из СписокСотрудников Цикл
			стрДанныеНачисленияЗарплаты.СотрудникиМассив.Добавить(стрСотрудник);
		КонецЦикла;
	Иначе
		Для каждого стрСотрудник из ЭтотОбъект.Начисления Цикл
			стрДанныеНачисленияЗарплаты.СотрудникиМассив.Добавить(стрСотрудник.Сотрудник);
		КонецЦикла;		
	КонецЕсли;

	стрДанныеНачисленияЗарплаты.булПерерасчет = Истина;
    стрДанныеНачисленияЗарплаты.булСортировкаПоСотрудникам = Истина;
	//
	МенеджерРасчета = Обработки.фуРасчетЗаработнойПлатыМск.Создать();
	МенеджерРасчета.Инициализация();
	МенеджерРасчета.ИсходныеДанные = стрДанныеНачисленияЗарплаты;
	МенеджерРасчета.ВыполнитьРасчетЗаработнойПлаты(); 	
    //
    
    ЗаполнитьЗначенияСвойств(ЭтотОбъект,МенеджерРасчета.ИсходныеДанные.ОбъектНачисленияЗарплаты);
	
КонецПроцедуры    

#КонецОбласти

