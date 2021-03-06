		
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	Если Параметры.Свойство("ДокументыМассив") Тогда
		
		ТаблицаИсточник.Очистить();
		Для каждого ДокументЭлемент Из Параметры.ДокументыМассив Цикл
			
			СтрокаИсточник = ТаблицаИсточник.Добавить();
			СтрокаИсточник.Документ = ДокументЭлемент;
			СтрокаИсточник.ВыборСтроки = Истина;
			
		КонецЦикла;
		
	КонецЕсли;  
	
КонецПроцедуры
		
&НаКлиенте
Процедура СоздатьКопиюДокументов(Команда)
	
	ВыбранныеСтрокиБулево = Ложь;
	Для каждого СтрокаИсточника Из ТаблицаИсточник Цикл
		
		Если СтрокаИсточника.ВыборСтроки Тогда
			ВыбранныеСтрокиБулево = Истина;
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
	Если ВыбранныеСтрокиБулево Тогда

		ТекстВопроса = НСтр("ru = 'Скопировать выбранные документы?'"); 
		ОповещениеПослеВопроса = Новый ОписаниеОповещения("ПередЗакрытиемЗавершение", ЭтотОбъект);
	    ПоказатьВопрос(ОповещениеПослеВопроса,ТекстВопроса,РежимДиалогаВопрос.ДаНет);

	Иначе
		
		ТекстВопроса = НСтр("ru = 'Перед копированием необходимо выделить строки. Выделить все строки?'"); 
		ОповещениеПослеВопроса = Новый ОписаниеОповещения("ВыделитьВсеСтрокиЗавершение", ЭтотОбъект);
	    ПоказатьВопрос(ОповещениеПослеВопроса,ТекстВопроса,РежимДиалогаВопрос.ДаНет);
		
	КонецЕсли;   

КонецПроцедуры

&НаКлиенте
Процедура ВыделитьВсеСтрокиЗавершение(РезультатВопроса, ДополнительныеПараметры) Экспорт
	
    Если РезультатВопроса = КодВозвратаДиалога.Да Тогда
		
		ВыбратьЭлементыНаСервере(Истина);		
		
	КонецЕсли;	
	
КонецПроцедуры

&НаСервере
Процедура СоздатьКопиюДокументовНаСервере()
	
	УИДТранзакции = Новый УникальныйИдентификатор;
	
	Для каждого СтрокаИсточника Из ТаблицаИсточник Цикл
		
		Если СтрокаИсточника.ВыборСтроки Тогда
			
			Если НЕ ЗначениеЗаполнено(СтрокаИсточника.Документ) Тогда
				Продолжить;
			КонецЕсли;
			
			ДокументКопия = СтрокаИсточника.Документ.Скопировать();
			ДокументКопия.Дата = ТекущаяДата();
			ДокументКопия.Комментарий = "Документ создан на основании: "+СтрокаИсточника.Документ;
			ДокументКопия.Ответственный = Пользователи.ТекущийПользователь();
			ДокументКопия.УИД_Транзакции = УИДТранзакции;
			
			ДокументКопия.Записать(РежимЗаписиДокумента.Запись);  
			Сообщить("Создана копия документа: "+СтрокаИсточника.Документ+" как: "+ДокументКопия.Ссылка);	
			
			СтрокаКопия = ТаблицаКопия.Добавить();
			СтрокаКопия.Документ = ДокументКопия.Ссылка;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Сообщить("Копирование документов завершено. УИД транзакции: ");
	Сообщить(УИДТранзакции);
	
КонецПроцедуры                                                                 

&НаКлиенте
Процедура ПередЗакрытиемЗавершение(РезультатВопроса, ДополнительныеПараметры) Экспорт
	
    Если РезультатВопроса = КодВозвратаДиалога.Да Тогда
   		СоздатьКопиюДокументовНаСервере();
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьВсе(Команда)
	
	ВыбратьЭлементыНаСервере(Истина);		
		
КонецПроцедуры     

&НаКлиенте
Процедура Очистить(Команда)

	ВыбратьЭлементыНаСервере(Ложь);		
	
КонецПроцедуры

&НаСервере
Процедура ВыбратьЭлементыНаСервере(ВыбратьВсе = Ложь)
	
	Для каждого СтрокаИсточника Из ТаблицаИсточник Цикл
		
		СтрокаИсточника.ВыборСтроки = ВыбратьВсе;
		
	КонецЦикла;
	
КонецПроцедуры







