
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	СинхронизироватьАктивностьДвиженийСПометкойУдаления();
	
КонецПроцедуры

// Устанавливает/снимает признак активности движений документа в зависимости от пометки удаления.
// Следует вызывать перед записью измененной пометки удаления.
// Помеченный на удаление документ не должен иметь активных движений.
// Не помеченный на удаление документ может иметь неактивные движения.
Процедура СинхронизироватьАктивностьДвиженийСПометкойУдаления()
	
	Если НЕ ПометкаУдаления Тогда
		// Не помеченный на удаление документ может иметь неактивные движения.
		// Однако, при снятии пометки удаления все движения становятся активными.
		Если ЭтоНовый() Или ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Ссылка, "ПометкаУдаления") = ПометкаУдаления Тогда
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	// Данные движений будут читаться только при неинтерактивной работе (например, при пометке на удаление документа
	// из списка). Поэтому чтение без контроля прав будет безопасным.
	УстановитьПривилегированныйРежим(Истина);
	РегистрыСДвижениями = Новый Массив;
	Для Каждого Движение Из Движения Цикл
		
		Если Движение.Записывать = Ложь Тогда // При работе формы набор может быть уже "потроган" (прочитан, модифицирован)
			// Набор никто не трогал
			Движение.Прочитать();
		КонецЕсли;
		
		Если Движение.Количество() > 0 Тогда
			РегистрыСДвижениями.Добавить(Движение);
		КонецЕсли;
		
	КонецЦикла;
	УстановитьПривилегированныйРежим(Ложь);
	
	Активность = НЕ ПометкаУдаления;
	Для Каждого Движение Из РегистрыСДвижениями Цикл
		
		Для Каждого Строка Из Движение Цикл
			
			Если Строка.Активность = Активность Тогда
				Продолжить;
			КонецЕсли;
			
			Строка.Активность   = Активность;
			Движение.Записывать = Истина; // На случай, если набор был прочитан выше
			
		КонецЦикла;
		
	КонецЦикла;
	
КонецПроцедуры

