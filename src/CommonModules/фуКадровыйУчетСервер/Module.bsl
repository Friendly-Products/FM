
#Область о // Общие процедуры и функции:

// +++ Чесноков М.С. 2021-09-22 F1-121
// Процедура удаляет те сканы, которые были удалены из табличной части кадрового документа.
//
// Параметры:
//  Объект	 - Объект - Объект кадрового документа перед записью. 
//
Процедура УдалениеСкановДокументаПередЗаписью(Объект) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	фмСканыДокументовКадры.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.фуСканыДокументовКадры КАК фмСканыДокументовКадры
		|ГДЕ
		|	фмСканыДокументовКадры.Источник = &Источник";
	
	Запрос.УстановитьПараметр("Источник", Объект.Ссылка);
	
	СканыДокументовТаблица = Запрос.Выполнить().Выгрузить();
	
	Для каждого СканДокументаСтрока Из СканыДокументовТаблица Цикл
		
		ПоискСкана = Новый Структура("СканДокумента",СканДокументаСтрока.Ссылка);
		НайденныеСтроки = Объект.СканыДокументовКадры.НайтиСтроки(ПоискСкана);
		
		Если НайденныеСтроки.Количество() = 0 Тогда
			СканДокументаОбъект = СканДокументаСтрока.Ссылка.ПолучитьОбъект();
			СканДокументаОбъект.Удалить();
		КонецЕсли; 
		
	КонецЦикла; 
	
	УстановитьПривилегированныйРежим(Ложь);
	
КонецПроцедуры
// --- Чесноков М.С. 2021-09-22 F1-121 

// +++ Чесноков М.С. 2021-08-27 F1-117
Процедура НастроитьВидимостьОкладовНаФорме(Элементы, ОбъектСсылка) Экспорт
	
	Если ОбъектСсылка = Неопределено Тогда
		Возврат;
	КонецЕсли; 
	
	Если Не ОбщегоНазначенияКлиентСервер.ЕстьРеквизитИлиСвойствоОбъекта(ОбъектСсылка, "Отдел") Тогда
		Возврат;
	КонецЕсли; 
	
	ВидимостьОкладовБулево = ПолучитьВидимостьОкладовПоРолям(ОбъектСсылка.Отдел);
	
	УстановитьВидимостьЭлемента(Элементы,"Оклад",ВидимостьОкладовБулево);
	// --- Чесноков М.С. 2021-08-27 F1-117
	
КонецПроцедуры
// --- Чесноков М.С. 2021-08-27 F1-117

// +++ Чесноков М.С. 2021-11-30 F1-152
Процедура УстановитьВидимостьЭлемента(ЭлементыФормы,ИмяРеквизита,ВидимостьБулево)
	
	Для каждого ЭлементФормы Из ЭлементыФормы Цикл
		
		Если СтрНайти(ВРег(ЭлементФормы.Имя),ВРег(ИмяРеквизита)) > 0 Тогда
			Если ТипЗнч(ЭлементыФормы[ЭлементФормы.Имя]) = Тип("ПолеФормы") Тогда
				ЭлементыФормы[ЭлементФормы.Имя].Видимость = ВидимостьБулево;	
			КонецЕсли; 
		КонецЕсли; 
		
	КонецЦикла; 
	
КонецПроцедуры 
// --- Чесноков М.С. 2021-11-30 F1-152 

// +++ Чесноков М.С. 2021-08-27 F1-117
// Функция - Получить видимость окладов по ролям
// 
// Возвращаемое значение:
//   - булево - будет видеть пользователь реквизиты на форме или нет. 
//
Функция ПолучитьВидимостьОкладовПоРолям(ОтделСсылка) Экспорт
	
	ВидимостьОкладовБулево = Ложь;
	
	Если РольДоступна("фуСотрудникСлужбыПерсонала") Тогда
		
		ВидимостьОкладовБулево = Истина;
		
		Если РольДоступна("фуОграниченияПоОкладам") Тогда
			
			Если ОтделСсылка = Справочники.фуОтделы.HR Тогда
				ВидимостьОкладовБулево = Ложь;
			КонецЕсли; 	
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если РольДоступна("ПолныеПрава") ИЛИ 
		 РольДоступна("фуРуководительСлужбыПерсонала") ИЛИ 
		 РольДоступна("фуРуководительФинансовойСлужбы") 
	Тогда
		ВидимостьОкладовБулево = Истина;
    КонецЕсли;

	Возврат ВидимостьОкладовБулево;	
	
КонецФункции                          
// --- Чесноков М.С. 2021-08-27 F1-117

// Процедура - Получить путь к родителям подразделения
//
// Параметры:
//  ОтделСсылка	 - ссылка	 - справочник подразделения
//  ИсходнаяСтрока		 - строка 	 - полный путь к подразделению
//
Процедура ПолучитьПутьКРодителямПодразделения(ОтделСсылка,ИсходнаяСтрока) 
    
    Если ЗначениеЗаполнено(ОтделСсылка.Родитель) Тогда
    	ПолучитьПутьКРодителямПодразделения(ОтделСсылка.Родитель,ИсходнаяСтрока);
        ИсходнаяСтрока = ОтделСсылка.Родитель.Наименование + "\" + ИсходнаяСтрока;
    КонецЕсли; 

КонецПроцедуры

// Функция - Получить полный путь к подразделению на сервере
//
// Параметры:
//  Отдел     - Отдел организации - ссылка
// 
// Возвращаемое значение:
//   - строка (полный путь с родителями подразделения).
//
Функция ПолучитьПолныйПутьКПодразделению(ОтделСсылка) Экспорт
    
    ПутьКРодителям = "";
    ПолучитьПутьКРодителямПодразделения(ОтделСсылка,ПутьКРодителям); 
    ПутьКРодителямПодразделенияСтрока = "\" + ПутьКРодителям + ОтделСсылка; 
    
    Возврат ПутьКРодителямПодразделенияСтрока; 
    
КонецФункции

// Функция - Ищет сотрудника в таблице значений СотрудникиТаблица, по строке стрТЗ. 
//
// Параметры:
//  СотрудникиТаблица	 - таблица значений	 - список сотрудников с ключевыми полями для поиска (Ф,И,О, ЛогинСРМ и пр.)
//  стрТЗ				 - структура  		 - структура для поиска в таблице значений с ключевыми полями.
// 
// Возвращаемое значение:
//   - Ссылка на справочник сотрудники. 
//
Функция НайтиСотрудникаПоСтроке(СотрудникиТаблица,стрТЗ) Экспорт 
	
	Сотрудник = Справочники.фуСотрудники.ПустаяСсылка();
	
    // Поиск по наименованию:
	Если Не ЗначениеЗаполнено(Сотрудник) И ЗначениеЗаполнено(стрТЗ.Наименование) Тогда
		
		НаименованиеПоискМассив = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(стрТЗ.Наименование, " ");
		Для каждого СотрудникСтрока Из СотрудникиТаблица Цикл

			НаименованиеВТаблицеМассив  = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(СотрудникСтрока.Наименование, " ");
			
			ПроцентПоиска = 0;
			Для каждого НаименованиеПоискЭлемент Из НаименованиеПоискМассив Цикл
				
				Для каждого НаименованиеВТаблице Из НаименованиеВТаблицеМассив Цикл
					
					Если НаименованиеПоискЭлемент = НаименованиеВТаблице Тогда
						ПроцентПоиска = ПроцентПоиска + 100 / НаименованиеПоискМассив.Количество();
					КонецЕсли;
					
				КонецЦикла;	
				
			КонецЦикла;

			Если ПроцентПоиска >= 80 Тогда          
				Сотрудник = СотрудникСтрока.Сотрудник;
				Прервать;
			КонецЕсли;
			
		КонецЦикла		
			
	КонецЕсли; 
            
	Возврат Сотрудник;
	
КонецФункции

// Функция - Получить всех сотрудников с кадровыми данными
//
// Параметры:
//  ПериодКадровыхДанных - дата	 - период на которые получаем актуальные кадровые данные
// 
// Возвращаемое значение:
//   - таблица значений 
//
Функция ПолучитьВсехСотрудниковСКадровымиДанными(ПериодКадровыхДанных = Неопределено) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	фуСотрудники.Ссылка КАК Сотрудник,
		|	фуСотрудники.Имя КАК Имя,
		|	фуСотрудники.Фамилия КАК Фамилия,
		|	фуСотрудники.Отчество КАК Отчество,
		|	фуСотрудники.ИНН КАК ИНН,
		|	фуСотрудники.ЛогинСРМ КАК ЛогинСРМ,
		|	фуСотрудники.ОкладОфициальный КАК ОкладОфициальный,
		|	фуСотрудники.ОкладУправленческий КАК ОкладУправленческий,
		|	фуСотрудники.ОфициальноеТрудоустройство КАК ОфициальноеТрудоустройство,
		|	фуСотрудники.ЧасоваяСтавка КАК ЧасоваяСтавка,
		|	фуСотрудники.Телефон КАК Телефон,
		|	фуСотрудники.Уволен КАК Уволен,
		|	фуСотрудники.Наименование КАК Наименование,
		|	фуСотрудники.ТабельныйНомерСРМ КАК ТабельныйНомерСРМ
		|ПОМЕСТИТЬ втСотрудники
		|ИЗ
		|	Справочник.фуСотрудники КАК фуСотрудники
		|ГДЕ
		|	НЕ фуСотрудники.ПометкаУдаления
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	фуКадроваяИсторияСотрудниковСрезПоследних.Сотрудник КАК Сотрудник,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.Организация КАК Организация,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.Отдел КАК Отдел,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.Должность КАК Должность,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.ОкладУправленческий КАК ОкладУправленческий,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.ДатаПриемаНаРаботу КАК ДатаПриемаНаРаботу,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.ДатаУвольнения КАК ДатаУвольнения
		|ПОМЕСТИТЬ втКадровыеДанные
		|ИЗ
		|	РегистрСведений.фуКадроваяИсторияСотрудников.СрезПоследних(
		|			&ПериодКадровыхДанных,
		|			Сотрудник В
		|				(ВЫБРАТЬ
		|					втСотрудники.Сотрудник КАК Сотрудник
		|				ИЗ
		|					втСотрудники КАК втСотрудники)) КАК фуКадроваяИсторияСотрудниковСрезПоследних
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	втСотрудники.Сотрудник КАК Сотрудник,
		|	втСотрудники.Имя КАК Имя,
		|	втСотрудники.Фамилия КАК Фамилия,
		|	втСотрудники.Отчество КАК Отчество,
		|	втСотрудники.ИНН КАК ИНН,
		|	втСотрудники.ЛогинСРМ КАК ЛогинСРМ,
		|	втСотрудники.ОкладОфициальный КАК ОкладОфициальный,
		|	втСотрудники.ОкладУправленческий КАК ОкладУправленческий,
		|	втСотрудники.ОфициальноеТрудоустройство КАК ОфициальноеТрудоустройство,
		|	втСотрудники.ЧасоваяСтавка КАК ЧасоваяСтавка,
		|	втСотрудники.Телефон КАК Телефон,
		|	втСотрудники.Уволен КАК Уволен,
		|	втКадровыеДанные.Организация КАК Организация,
		|	втКадровыеДанные.Отдел КАК Отдел,
		|	втКадровыеДанные.Должность КАК Должность,
		|	втКадровыеДанные.ОкладУправленческий КАК ОкладУправленческий1,
		|	втКадровыеДанные.ДатаПриемаНаРаботу КАК ДатаПриемаНаРаботу,
		|	втКадровыеДанные.ДатаУвольнения КАК ДатаУвольнения,
		|	втСотрудники.Наименование КАК Наименование,
		|	втСотрудники.ТабельныйНомерСРМ КАК ТабельныйНомерСРМ
		|ИЗ
		|	втСотрудники КАК втСотрудники
		|		ЛЕВОЕ СОЕДИНЕНИЕ втКадровыеДанные КАК втКадровыеДанные
		|		ПО втСотрудники.Сотрудник = втКадровыеДанные.Сотрудник";
	
	Если Не ЗначениеЗаполнено(ПериодКадровыхДанных) Тогда
		ПериодКадровыхДанных = КонецДня(ТекущаяДата());
	КонецЕсли;
	
	Запрос.УстановитьПараметр("ПериодКадровыхДанных", ПериодКадровыхДанных);
	
	ТаблицаЗначений = Запрос.Выполнить().Выгрузить();
	ТаблицаЗначений.Индексы.Добавить("Сотрудник");	
	ТаблицаЗначений.Индексы.Добавить("Фамилия");	
	ТаблицаЗначений.Индексы.Добавить("Имя");	
	ТаблицаЗначений.Индексы.Добавить("Отчество");	
	ТаблицаЗначений.Индексы.Добавить("ЛогинСРМ");	
	ТаблицаЗначений.Индексы.Добавить("Наименование");	
    
    // Предварительная обработка данных:
    Для каждого ТаблицаСтрока Из ТаблицаЗначений Цикл
        ТаблицаСтрока.Фамилия       = ОбработатьСтрокуДляУнифицированногоПоиска(ТаблицаСтрока.Фамилия);
        ТаблицаСтрока.Имя           = ОбработатьСтрокуДляУнифицированногоПоиска(ТаблицаСтрока.Имя);	
        ТаблицаСтрока.Отчество      = ОбработатьСтрокуДляУнифицированногоПоиска(ТаблицаСтрока.Отчество);	
    	ТаблицаСтрока.ЛогинСРМ      = ОбработатьСтрокуДляУнифицированногоПоиска(ТаблицаСтрока.ЛогинСРМ);
    	ТаблицаСтрока.Наименование  = СокрЛП(ВРег(ТаблицаСтрока.Наименование));
    КонецЦикла; 
    
	Возврат ТаблицаЗначений;
	
КонецФункции

Функция ОбработатьСтрокуДляУнифицированногоПоиска(ПараметрСтрока)
    
    Возврат ВРег(СтрЗаменить(ПараметрСтрока," ",""));
    
КонецФункции
 
Функция ПолучитьСтруктуруКадровыхДанных()
	
	КадровыеДанныеСтруктура = Новый Структура;
	
	КадровыеДанныеСтруктура.Вставить("Сотрудник");
	КадровыеДанныеСтруктура.Вставить("Организация");
	КадровыеДанныеСтруктура.Вставить("ОкладОфициальный");
	КадровыеДанныеСтруктура.Вставить("ОкладУправленческий");
	КадровыеДанныеСтруктура.Вставить("Должность");
	КадровыеДанныеСтруктура.Вставить("Отдел");
	КадровыеДанныеСтруктура.Вставить("Департамент");
	КадровыеДанныеСтруктура.Вставить("Группа");	
	КадровыеДанныеСтруктура.Вставить("ДатаПриемаНаРаботу");
	КадровыеДанныеСтруктура.Вставить("ДатаУвольнения");
	// +++ Чесноков М.С. 2021-12-08 F1-162
	КадровыеДанныеСтруктура.Вставить("МотивационнаяСхема");
	// --- Чесноков М.С. 2021-12-08 F1-162 
		
	Возврат КадровыеДанныеСтруктура; 	
		
КонецФункции

Функция ПолучитьКадровыеДанныеСотрудника(Сотрудник,Дата = Неопределено) Экспорт
	
    Запрос = Новый Запрос;
    Запрос.Текст = 
    	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
    	|	фуКадроваяИсторияСотрудниковСрезПоследних.Сотрудник КАК Сотрудник,
    	|	фуКадроваяИсторияСотрудниковСрезПоследних.Должность КАК Должность,
    	|	фуКадроваяИсторияСотрудниковСрезПоследних.Отдел КАК Отдел,
    	|	фуКадроваяИсторияСотрудниковСрезПоследних.Департамент КАК Департамент,
    	|	фуКадроваяИсторияСотрудниковСрезПоследних.Группа КАК Группа,
    	|	фуКадроваяИсторияСотрудниковСрезПоследних.Организация КАК Организация,
    	|	фуКадроваяИсторияСотрудниковСрезПоследних.ДатаПриемаНаРаботу КАК ДатаПриемаНаРаботу,
    	|	фуКадроваяИсторияСотрудниковСрезПоследних.ДатаУвольнения КАК ДатаУвольнения,
    	|	фуКадроваяИсторияСотрудниковСрезПоследних.ОкладОфициальный КАК ОкладОфициальный,
    	|	фуКадроваяИсторияСотрудниковСрезПоследних.ОкладУправленческий КАК ОкладУправленческий,
    	|	фуКадроваяИсторияСотрудниковСрезПоследних.МотивационнаяСхема КАК МотивационнаяСхема,
    	|	фуКадроваяИсторияСотрудниковСрезПоследних.ВалютаВыплатыЗарплаты КАК ВалютаВыплатыЗарплаты,
    	|	фуКадроваяИсторияСотрудниковСрезПоследних.Руководитель КАК Руководитель,
    	|	ВЫБОР
    	|		КОГДА фуКадроваяИсторияСотрудниковСрезПоследних.ДатаУвольнения = ДАТАВРЕМЯ(1, 1, 1)
    	|			ТОГДА ЛОЖЬ
    	|		ИНАЧЕ ИСТИНА
    	|	КОНЕЦ КАК Уволен
    	|ИЗ
    	|	РегистрСведений.фуКадроваяИсторияСотрудников.СрезПоследних(&Дата, Сотрудник = &Сотрудник) КАК фуКадроваяИсторияСотрудниковСрезПоследних";
		
	// +++ Чесноков М.С. 2022-01-28 F1-183
	Если Дата = Неопределено Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст,"&Дата","");	
	КонецЕсли;
	// --- Чесноков М.С. 2022-01-28 F1-183	
		
	Запрос.УстановитьПараметр("Дата", Дата);
	Запрос.УстановитьПараметр("Сотрудник", Сотрудник);
	
	// +++ Чесноков М.С. 2022-01-28 F1-183
	// РезультатЗапроса = Запрос.Выполнить().Выбрать();
	КадровыеДанныеСтруктура = Новый Структура;
	РезультатЗапроса = Запрос.Выполнить().Выгрузить();
	Для каждого Колонка Из РезультатЗапроса.Колонки Цикл
		КадровыеДанныеСтруктура.Вставить(Колонка.Имя);	
	КонецЦикла;

	//Пока РезультатЗапроса.Следующий() Цикл
	//	ЗаполнитьЗначенияСвойств(КадровыеДанныеСтруктура,РезультатЗапроса);
	//КонецЦикла;	
	Для каждого РезультатСтрока Из РезультатЗапроса Цикл
		ЗаполнитьЗначенияСвойств(КадровыеДанныеСтруктура,РезультатСтрока);
	КонецЦикла;
	// --- Чесноков М.С. 2022-01-28 F1-183
	
	Возврат КадровыеДанныеСтруктура; 
	
КонецФункции

#КонецОбласти 

#Область о // Отправка почтового сообщения о появлении нового сотрудника:

// +++ Чесноков М.С. 2021-10-25 F1-133
Процедура ОтправитьОповещениеОДобавленииНовогоСотрудникаНаЭлектроннуюПочтуОтветсвеннымЛицам(ОбъектСсылка) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	Если Не Константы.ОтправкаОповещенийОДобавленииНовогоСотрудника.Получить() Тогда
		Возврат;
	КонецЕсли; 
	УстановитьПривилегированныйРежим(Ложь);
	
	Если ТипЗнч(ОбъектСсылка) <> Тип("ДокументСсылка.фуПриемНаРаботу") Тогда
	    Возврат;
	КонецЕсли;
	
	Если ОбъектСсылка.СтатусДокумента <> Перечисления.фуСтатусыДокументов.КСогласованию Тогда
	    Возврат;
	КонецЕсли;
	
	Если ОбъектСсылка.Сотрудник.ОтправленоПисьмоПриДобавленииНового Тогда
		Возврат;
	КонецЕсли; 
	
	ТекущийПользователь = Пользователи.ТекущийПользователь();

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	ГруппыДоступаПользователи.Пользователь КАК Пользователь
		|ПОМЕСТИТЬ втОтветсвенныеПользователи
		|ИЗ
		|	Справочник.ГруппыДоступа.Пользователи КАК ГруппыДоступаПользователи
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ПрофилиГруппДоступа.Роли КАК ПрофилиГруппДоступаРоли
		|		ПО ГруппыДоступаПользователи.Ссылка.Профиль = ПрофилиГруппДоступаРоли.Ссылка
		|ГДЕ
		|	ПрофилиГруппДоступаРоли.Роль.Имя = &Роль
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	втОтветсвенныеПользователи.Пользователь КАК Пользователь,
		|	ПользователиКонтактнаяИнформация.АдресЭП КАК АдресЭП
		|ИЗ
		|	Справочник.Пользователи.КонтактнаяИнформация КАК ПользователиКонтактнаяИнформация
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ втОтветсвенныеПользователи КАК втОтветсвенныеПользователи
		|		ПО ПользователиКонтактнаяИнформация.Ссылка = втОтветсвенныеПользователи.Пользователь
		|ГДЕ
		|	ПользователиКонтактнаяИнформация.Вид = &ВидыКонтактнойИнформацииEmailСотрудника";
	
	Запрос.УстановитьПараметр("Роль", "фуОтправкаОповещенияОДобавленииНовогоСотрудника");
	Запрос.УстановитьПараметр("ВидыКонтактнойИнформацииEmailСотрудника", Справочники.ВидыКонтактнойИнформации.EmailПользователя);
	
	УстановитьПривилегированныйРежим(Истина);
	АдресаЭлектроннойПочтыТаблица = Запрос.Выполнить().Выгрузить();
	УстановитьПривилегированныйРежим(Ложь);
	
	Если АдресаЭлектроннойПочтыТаблица.Количество() = 0 Тогда
		Возврат;
	КонецЕсли; 
	
	АдресЭлектроннойПочтыМассив = АдресаЭлектроннойПочтыТаблица.ВыгрузитьКолонку("АдресЭП");
	Если ОтправитьПисьмоОДобавленииНовогоСотрудника(АдресЭлектроннойПочтыМассив,ОбъектСсылка) Тогда
		
		СотрудникОбъект = ОбъектСсылка.Сотрудник.ПолучитьОбъект();
		СотрудникОбъект.ОтправленоПисьмоПриДобавленииНового = Истина;
		СотрудникОбъект.Записать();
		
	КонецЕсли; 
	
КонецПроцедуры                                       
// --- Чесноков М.С. 2021-10-25 F1-133                                            

// +++ Чесноков М.С. 2021-10-25 F1-133                                            
Функция ОтправитьПисьмоОДобавленииНовогоСотрудника(АдресЭлектроннойПочтыМассив,ОбъектСсылка)
	
	ПисьмоОтправлено = Ложь;
	ТипОповещенияСтрока = "Отправка оповещения о добавлении нового сотрудника";
	
	ПочтовыйАдресПолучателя = "";
	Для каждого ПочтовыйАдресПолучателяЭлемент Из АдресЭлектроннойПочтыМассив Цикл
		ПочтовыйАдресПолучателя = ПочтовыйАдресПолучателя + Строка(ПочтовыйАдресПолучателяЭлемент) + "; ";	
	КонецЦикла;
	
	Попытка
		ПриведенныйПочтовыйАдрес = ОбщегоНазначенияКлиентСервер.РазобратьСтрокуСПочтовымиАдресами(ПочтовыйАдресПолучателя);
	Исключение
		ЗаписьЖурналаРегистрации(ТипОповещенияСтрока, 
                                 УровеньЖурналаРегистрации.Ошибка, 
                                 , 
                                 ТекущаяДата(), 
                                 КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
	
	ПараметрыПисьма = Новый Структура;
	Если ЗначениеЗаполнено(ПриведенныйПочтовыйАдрес) Тогда
		ПараметрыПисьма.Вставить("Кому", ПриведенныйПочтовыйАдрес);
	КонецЕсли;
	
	СотрудникСсылка = ОбъектСсылка.Сотрудник;
	ФИОСтрока = СотрудникСсылка.Наименование;
	ДатаПриемаНаРаботуСтрока = Формат(ОбъектСсылка.ДатаПриемаНаРаботу,"ДФ=dd.MM.yyyy");
	// Тема письма:
	ТемаПисьмаСтрока = "Добавление нового сотрудника " + ФИОСтрока 
					 + " от " + ДатаПриемаНаРаботуСтрока;
	// Тело письма:
	ТелоПисьмаСтрока = "Добрый день. В 1с добавлен новый сотрудник " + ФИОСтрока
	                 + " от "+ ДатаПриемаНаРаботуСтрока + "."
					 + Символы.ПС
					 + Символы.ПС;
					 
	ПереченьКлючевыхРеквизитовСотрудника = ПолучитьПереченьКлючевыхРеквизитовСотрудника(СотрудникСсылка);
	Если ПереченьКлючевыхРеквизитовСотрудника.Количество() > 0 Тогда
		
		ТелоПисьмаСтрока = ТелоПисьмаСтрока 
		 				 + "Ключевые реквизиты:"
						 + Символы.ПС;
		 				 
		Для каждого КлючевойРеквизит Из ПереченьКлючевыхРеквизитовСотрудника Цикл

			Для Каждого КлючИЗначение Из КлючевойРеквизит Цикл
				ТелоПисьмаСтрока = ТелоПисьмаСтрока 
 				 	 + КлючИЗначение.Ключ + ": "
					 + КлючИЗначение.Значение + ";"
					 + Символы.ПС;
			КонецЦикла;	
		
		КонецЦикла; 
		
	КонецЕсли; 
	      	
	ПараметрыПисьма.Вставить("Тема", ТемаПисьмаСтрока);
	ПараметрыПисьма.Вставить("Тело", ТелоПисьмаСтрока);
	//ПараметрыПисьма.Вставить("ТипТекста", "HTML"); // RichText
	
	СистемнаяУчетнаяЗаписьЭлектроннойПочты = Справочники.УчетныеЗаписиЭлектроннойПочты.СистемнаяУчетнаяЗаписьЭлектроннойПочты;
	
	Попытка
		РаботаСПочтовымиСообщениями.ОтправитьПочтовоеСообщение(СистемнаяУчетнаяЗаписьЭлектроннойПочты, ПараметрыПисьма);
		
		ТекстОповещения = "Успешно отправлено письмо о добавлении нового сотрудника: "
						+ ФИОСтрока
						+ " получателям: "
						+ ПочтовыйАдресПолучателя;
		
		ЗаписьЖурналаРегистрации(ТипОповещенияСтрока, 
                                 УровеньЖурналаРегистрации.Информация, 
                                 , 
                                 ТекущаяДата(), 
                                 ТекстОповещения);
								 
		ПисьмоОтправлено = Истина;						 
	Исключение
		ИнформацияОбОшибкеСтрока = ИнформацияОбОшибке();
		
		ЗаписьЖурналаРегистрации(ТипОповещенияСтрока, 
                                 УровеньЖурналаРегистрации.Ошибка, 
                                 , 
                                 ТекущаяДата(), 
                                 ИнформацияОбОшибкеСтрока);
	КонецПопытки;                
	
	Возврат ПисьмоОтправлено;
		                                                          
КонецФункции                                                    
// --- Чесноков М.С. 2021-10-25 F1-133                                             

// +++ Чесноков М.С. 2021-10-25 F1-133                                             
Функция ПолучитьПереченьКлючевыхРеквизитовСотрудника(СотрудникСсылка)
	                                                                             
	ПереченьРеквизитов = Новый Массив;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	фуКадроваяИсторияСотрудниковСрезПоследних.Сотрудник КАК Сотрудник,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.Организация КАК Организация,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.Отдел КАК Отдел,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.Должность КАК Должность,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.ОкладУправленческий КАК ОкладУправленческий,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.ДатаПриемаНаРаботу КАК ДатаПриемаНаРаботу,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.Регистратор.Ответственный КАК Ответственный
		|ИЗ
		|	РегистрСведений.фуКадроваяИсторияСотрудников.СрезПоследних(, Сотрудник = &Сотрудник) КАК фуКадроваяИсторияСотрудниковСрезПоследних
		|ГДЕ
		|	фуКадроваяИсторияСотрудниковСрезПоследних.ВидСобытия = &ВидСобытияПриемНаРаботу";
	
	Запрос.УстановитьПараметр("ВидСобытияПриемНаРаботу", Перечисления.фуВидыКадровыхСобытий.ПриемНаРаботу);
	Запрос.УстановитьПараметр("Сотрудник", СотрудникСсылка);
	
	ТаблицаЗначений = Запрос.Выполнить().Выгрузить();
	Если ТаблицаЗначений.Количество() > 0 Тогда
		
		Для каждого СтрокаТаблицы Из ТаблицаЗначений Цикл
			
			ДанныеСтруктура = Новый Структура;
			Для каждого ИмяСтолбца Из ТаблицаЗначений.Колонки Цикл
				ДанныеСтруктура.Вставить(ИмяСтолбца.Имя,СтрокаТаблицы[ИмяСтолбца.Имя]);
			КонецЦикла;
			
			ПереченьРеквизитов.Добавить(ДанныеСтруктура);
			
		КонецЦикла;     		
		
	КонецЕсли;
	
	Возврат ПереченьРеквизитов;
		
КонецФункции
// --- Чесноков М.С. 2021-10-25 F1-133                                             

#КонецОбласти 

#Область о //Работающие сотрудники за период:

// Функция - Возвращает текст запроса по сотрудникам
//
// Параметры:
//  ДанныеНачисленияЗарплаты - структура - Структура данных для запроса
// 
// Возвращаемое значение:
//   - Возвращает текст запроса по сотрудникам
//
Функция ПолучитьТекстЗапроса_Сотрудники(ДанныеНачисленияЗарплаты)

	стрТекстЗапроса =	
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	фуКадроваяИсторияСотрудниковСрезПоследних.Сотрудник КАК Сотрудник,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.Организация КАК Организация,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.Отдел КАК Отдел,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.ВидСобытия КАК ВидСобытия,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.Должность КАК Должность,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.ОкладУправленческий КАК ОкладУправленческий,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.ДатаПриемаНаРаботу КАК ДатаПриемаНаРаботу,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.ДатаУвольнения КАК ДатаУвольнения
		|ПОМЕСТИТЬ втРаботающиеСотрудникиНаНачалоПериода
		|ИЗ
		|	РегистрСведений.фуКадроваяИсторияСотрудников.СрезПоследних(
		|			&Дата1,
		|			Организация = &Организация
		|				И Отдел = &Отдел
		|				И Сотрудник В (&СотрудникиМассив)) КАК фуКадроваяИсторияСотрудниковСрезПоследних
		|ГДЕ
		|	фуКадроваяИсторияСотрудниковСрезПоследних.ВидСобытия В(&ВидыСобытийПриема)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	фуКадроваяИсторияСотрудниковСрезПоследних.Сотрудник КАК Сотрудник,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.Организация КАК Организация,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.Отдел КАК Отдел,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.ВидСобытия КАК ВидСобытия,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.Должность КАК Должность,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.ОкладУправленческий КАК ОкладУправленческий,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.ДатаПриемаНаРаботу КАК ДатаПриемаНаРаботу,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.ДатаУвольнения КАК ДатаУвольнения
		|ПОМЕСТИТЬ втРаботающиеСотрудникиНаКонецПериода
		|ИЗ
		|	РегистрСведений.фуКадроваяИсторияСотрудников.СрезПоследних(
		|			&Дата2,
		|			Организация = &Организация
		|				И Отдел = &Отдел
		|				И Сотрудник В (&СотрудникиМассив)) КАК фуКадроваяИсторияСотрудниковСрезПоследних
		|ГДЕ
		|	фуКадроваяИсторияСотрудниковСрезПоследних.ВидСобытия В(&ВидыСобытийПриема)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	фуКадроваяИсторияСотрудниковСрезПоследних.Сотрудник КАК Сотрудник,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.Организация КАК Организация,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.Отдел КАК Отдел,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.ВидСобытия КАК ВидСобытия,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.Должность КАК Должность,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.ОкладУправленческий КАК ОкладУправленческий,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.ДатаПриемаНаРаботу КАК ДатаПриемаНаРаботу,
		|	фуКадроваяИсторияСотрудниковСрезПоследних.ДатаУвольнения КАК ДатаУвольнения
		|ПОМЕСТИТЬ втУволенныеСотрудникиНаНачалоПериода
		|ИЗ
		|	РегистрСведений.фуКадроваяИсторияСотрудников.СрезПоследних(
		|			&Дата1,
		|			Организация = &Организация
		|				И Отдел = &Отдел
		|				И Сотрудник В (&СотрудникиМассив)) КАК фуКадроваяИсторияСотрудниковСрезПоследних
		|ГДЕ
		|	фуКадроваяИсторияСотрудниковСрезПоследних.ВидСобытия = ЗНАЧЕНИЕ(Перечисление.фуВидыКадровыхСобытий.Увольнение)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	фмКадроваяИсторияСотрудников.Сотрудник КАК Сотрудник,
		|	фмКадроваяИсторияСотрудников.Организация КАК Организация,
		|	фмКадроваяИсторияСотрудников.Отдел КАК Отдел,
		|	фмКадроваяИсторияСотрудников.ВидСобытия КАК ВидСобытия,
		|	фмКадроваяИсторияСотрудников.Должность КАК Должность,
		|	фмКадроваяИсторияСотрудников.ОкладУправленческий КАК ОкладУправленческий,
		|	фмКадроваяИсторияСотрудников.ДатаПриемаНаРаботу КАК ДатаПриемаНаРаботу,
		|	фмКадроваяИсторияСотрудников.ДатаУвольнения КАК ДатаУвольнения
		|ПОМЕСТИТЬ втУволенныеВТекущемПериоде
		|ИЗ
		|	РегистрСведений.фуКадроваяИсторияСотрудников КАК фмКадроваяИсторияСотрудников
		|ГДЕ
		|	фмКадроваяИсторияСотрудников.Период >= &Дата1
		|	И фмКадроваяИсторияСотрудников.Период <= &Дата2
		|	И фмКадроваяИсторияСотрудников.ВидСобытия = ЗНАЧЕНИЕ(Перечисление.фуВидыКадровыхСобытий.Увольнение)
		|	И фмКадроваяИсторияСотрудников.Организация = &Организация
		|	И фмКадроваяИсторияСотрудников.Отдел = &Отдел
		|	И фмКадроваяИсторияСотрудников.Сотрудник В(&СотрудникиМассив)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	втРаботающиеСотрудникиНаНачалоПериода.Сотрудник КАК Сотрудник,
		|	втРаботающиеСотрудникиНаНачалоПериода.Организация КАК Организация,
		|	втРаботающиеСотрудникиНаНачалоПериода.Отдел КАК Отдел,
		|	втРаботающиеСотрудникиНаНачалоПериода.ВидСобытия КАК ВидСобытия,
		|	втРаботающиеСотрудникиНаНачалоПериода.Должность КАК Должность,
		|	втРаботающиеСотрудникиНаНачалоПериода.ОкладУправленческий КАК ОкладУправленческий,
		|	втРаботающиеСотрудникиНаНачалоПериода.ДатаПриемаНаРаботу КАК ДатаПриемаНаРаботу,
		|	втРаботающиеСотрудникиНаНачалоПериода.ДатаУвольнения КАК ДатаУвольнения
		|ПОМЕСТИТЬ втОбъединение
		|ИЗ
		|	втРаботающиеСотрудникиНаНачалоПериода КАК втРаботающиеСотрудникиНаНачалоПериода
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	втРаботающиеСотрудникиНаКонецПериода.Сотрудник,
		|	втРаботающиеСотрудникиНаКонецПериода.Организация,
		|	втРаботающиеСотрудникиНаКонецПериода.Отдел,
		|	втРаботающиеСотрудникиНаКонецПериода.ВидСобытия,
		|	втРаботающиеСотрудникиНаКонецПериода.Должность,
		|	втРаботающиеСотрудникиНаКонецПериода.ОкладУправленческий,
		|	втРаботающиеСотрудникиНаКонецПериода.ДатаПриемаНаРаботу,
		|	втРаботающиеСотрудникиНаКонецПериода.ДатаУвольнения
		|ИЗ
		|	втРаботающиеСотрудникиНаКонецПериода КАК втРаботающиеСотрудникиНаКонецПериода
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	втУволенныеСотрудникиНаНачалоПериода.Сотрудник,
		|	втУволенныеСотрудникиНаНачалоПериода.Организация,
		|	втУволенныеСотрудникиНаНачалоПериода.Отдел,
		|	втУволенныеСотрудникиНаНачалоПериода.ВидСобытия,
		|	втУволенныеСотрудникиНаНачалоПериода.Должность,
		|	втУволенныеСотрудникиНаНачалоПериода.ОкладУправленческий,
		|	втУволенныеСотрудникиНаНачалоПериода.ДатаПриемаНаРаботу,
		|	втУволенныеСотрудникиНаНачалоПериода.ДатаУвольнения
		|ИЗ
		|	втУволенныеСотрудникиНаНачалоПериода КАК втУволенныеСотрудникиНаНачалоПериода
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	втУволенныеВТекущемПериоде.Сотрудник,
		|	втУволенныеВТекущемПериоде.Организация,
		|	втУволенныеВТекущемПериоде.Отдел,
		|	втУволенныеВТекущемПериоде.ВидСобытия,
		|	втУволенныеВТекущемПериоде.Должность,
		|	втУволенныеВТекущемПериоде.ОкладУправленческий,
		|	втУволенныеВТекущемПериоде.ДатаПриемаНаРаботу,
		|	втУволенныеВТекущемПериоде.ДатаУвольнения
		|ИЗ
		|	втУволенныеВТекущемПериоде КАК втУволенныеВТекущемПериоде
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	втОбъединение.Сотрудник КАК Сотрудник,
		|	втОбъединение.Организация КАК Организация,
		|	втОбъединение.Отдел КАК Отдел,
		|	втОбъединение.Должность КАК Должность,
		|	втОбъединение.ОкладУправленческий КАК ОкладУправленческий,
		|	втОбъединение.ДатаПриемаНаРаботу КАК ДатаПриемаНаРаботу,
		|	втОбъединение.ДатаУвольнения КАК ДатаУвольнения,
		|	втОбъединение.Сотрудник.ОкладОфициальный КАК ОкладРазмер,
		|	втОбъединение.Сотрудник.ЛогинСРМ КАК ЛогинСРМ,
		|	втОбъединение.Сотрудник.Фамилия КАК Фамилия,
		|	втОбъединение.Сотрудник.Имя КАК Имя,
		|	втОбъединение.Сотрудник.Отчество КАК Отчество,
		|	втОбъединение.Сотрудник.Наименование КАК Наименование,
		|	втОбъединение.Сотрудник.ЧасоваяСтавка КАК ЧасоваяСтавка,
		|	втОбъединение.Сотрудник.ВалютаВыплатыЗарплаты КАК ВалютаВыплатыЗарплаты
		|ИЗ
		|	втОбъединение КАК втОбъединение
		|ГДЕ
		|	втОбъединение.ВидСобытия <> ЗНАЧЕНИЕ(Перечисление.фуВидыКадровыхСобытий.Увольнение)
		|
		|СГРУППИРОВАТЬ ПО
		|	втОбъединение.Сотрудник,
		|	втОбъединение.Организация,
		|	втОбъединение.Отдел,
		|	втОбъединение.Сотрудник.ОкладОфициальный,
		|	втОбъединение.Сотрудник.ЛогинСРМ,
		|	втОбъединение.Сотрудник.Фамилия,
		|	втОбъединение.Сотрудник.Имя,
		|	втОбъединение.Сотрудник.Отчество,
		|	втОбъединение.Сотрудник.Наименование,
		|	втОбъединение.Сотрудник.ЧасоваяСтавка,
		|	втОбъединение.Сотрудник.ВалютаВыплатыЗарплаты,
		|	втОбъединение.Должность,
		|	втОбъединение.ОкладУправленческий,
		|	втОбъединение.ДатаПриемаНаРаботу,
		|	втОбъединение.ДатаУвольнения
		|
		|УПОРЯДОЧИТЬ ПО
		|	втОбъединение.Сотрудник.Наименование";
	
	Если Не ЗначениеЗаполнено(ДанныеНачисленияЗарплаты.СотрудникиМассив) Тогда
		
		стрТекстЗапроса = СтрЗаменить(стрТекстЗапроса,"фуКадроваяИсторияСотрудников.Сотрудник В (&СотрудникиМассив)","Истина");
		стрТекстЗапроса = СтрЗаменить(стрТекстЗапроса,"Сотрудник В (&СотрудникиМассив)","Истина");
		
	КонецЕсли;
	
    Если Не ЗначениеЗаполнено(ДанныеНачисленияЗарплаты.Организация) Тогда
        стрТекстЗапроса = СтрЗаменить(стрТекстЗапроса,"фуКадроваяИсторияСотрудников.Организация = &Организация","Истина");
		стрТекстЗапроса = СтрЗаменить(стрТекстЗапроса,"Организация = &Организация","Истина");
	КонецЕсли;		
	
	Возврат стрТекстЗапроса;
	
КонецФункции

// Функция - Получить структуру параметров для запроса сотрудники
// 
// Возвращаемое значение:
//   - Структура параметров запроса.
//
Функция ПолучитьСтруктуруПараметровДляЗапроса_Сотрудники() Экспорт
	
	СтруктураПараметров = Новый Структура;
	
	СтруктураПараметров.Вставить("Организация",Справочники.фуОрганизации.ПустаяСсылка());
	СтруктураПараметров.Вставить("Отдел",Справочники.фуОтделы.ПустаяСсылка());
	СтруктураПараметров.Вставить("Дата1",НачалоГода(ТекущаяДата()));
	СтруктураПараметров.Вставить("Дата2",КонецГода(ТекущаяДата()));
	СтруктураПараметров.Вставить("СотрудникиМассив",Новый Массив);
	
	Возврат СтруктураПараметров;
	
КонецФункции

// Функция возвращает таблицу значений работающих сотрудников за период.
//
//	Параметры:
//
//	ПараметрыЗапроса - структура:
//		Организация	- ссылка, справочник "Организации";
//		Отдел - ссылка, справочник "Подразделения"
//		Дата1 - дата, начало перода;
//		Дата2 - дата, конец периода;
//		СотрудникиМассив - массив, перечень сотрудников;
//
//		Все параметры могут быть заданы как пустые.
Функция ПолучитьТаблицуЗначенийДляЗаполнения_Сотрудники(ПараметрыЗапроса) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = ПолучитьТекстЗапроса_Сотрудники(ПараметрыЗапроса); 
	
	массВидыСобытийПриема = Новый Массив;
	массВидыСобытийПриема.Добавить(Перечисления.фуВидыКадровыхСобытий.ПриемНаРаботу);
	массВидыСобытийПриема.Добавить(Перечисления.фуВидыКадровыхСобытий.КадровоеИзменение);
	Запрос.УстановитьПараметр("ВидыСобытийПриема", массВидыСобытийПриема);
	
	УстановитьПараметрЗапроса(Запрос,ПараметрыЗапроса,"Организация");
	УстановитьПараметрЗапроса(Запрос,ПараметрыЗапроса,"Отдел");
	УстановитьПараметрЗапроса(Запрос,ПараметрыЗапроса,"Дата1");
	УстановитьПараметрЗапроса(Запрос,ПараметрыЗапроса,"Дата2");
	УстановитьПараметрЗапроса(Запрос,ПараметрыЗапроса,"СотрудникиМассив");
	
	Если ПараметрыЗапроса.Свойство("Организация") Тогда
		Запрос.УстановитьПараметр("Организация", ПараметрыЗапроса.Организация);	
	КонецЕсли;
    
    тз = Запрос.Выполнить().Выгрузить(); 
    
	Возврат тз;
	
КонецФункции

Процедура УстановитьПараметрЗапроса(Запрос,ПараметрыЗапроса,ИмяПараметра);
	
	Если ПараметрыЗапроса.Свойство(ИмяПараметра) Тогда
		Запрос.УстановитьПараметр(ИмяПараметра, ПараметрыЗапроса[ИмяПараметра]);	
	КонецЕсли;

КонецПроцедуры

#КонецОбласти
