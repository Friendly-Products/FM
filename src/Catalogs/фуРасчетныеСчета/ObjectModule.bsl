
Процедура ПередЗаписью(Отказ)
	
	Если Не ЗначениеЗаполнено(ЭтотОбъект.ВалютаСчета) Тогда
		ЭтотОбъект.ВалютаСчета = фуОперацииСВалютамиКлиентСервер.НайтиВалютуПоСтроке(ЭтотОбъект.Наименование);
    КонецЕсли;
	
КонецПроцедуры
