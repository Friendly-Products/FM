
Процедура ПередЗаписью(Отказ)
	
	// Тест:
	ЗаполнитьФИО(ЭтотОбъект.Наименование);
    
    Для каждого КонтактнаяИнформацияСтрока Из ЭтотОбъект.КонтактнаяИнформация Цикл
        
        Если КонтактнаяИнформацияСтрока.Тип = Перечисления.ТипыКонтактнойИнформации.АдресЭлектроннойПочты Тогда
            ЭтотОбъект.АдресЭлектроннойПочты = КонтактнаяИнформацияСтрока.Представление;
        ИначеЕсли КонтактнаяИнформацияСтрока.Тип = Перечисления.ТипыКонтактнойИнформации.Телефон Тогда 
            ЭтотОбъект.Телефон = КонтактнаяИнформацияСтрока.Представление;    
        КонецЕсли; 
        
    КонецЦикла; 
    
КонецПроцедуры

Процедура ЗаполнитьФИО(Наименование) Экспорт

    Если ЭтотОбъект.ЭтоГруппа Тогда
    	Возврат;
    КонецЕсли; 
    
	Если ЗначениеЗаполнено(Наименование) Тогда
		
		СтруктураФИО = ФизическиеЛицаКлиентСервер.ЧастиИмени(Наименование);
		
		ЭтотОбъект.Фамилия = СтруктураФИО.Фамилия;
		ЭтотОбъект.Имя = СтруктураФИО.Имя;
		ЭтотОбъект.Отчество = СтруктураФИО.Отчество;
	
	КонецЕсли;
	
КонецПроцедуры