`include "APB_master.sv"
`include "Sum.sv"
module Sum_tb;

reg PCLK = 0;           // сигнал синхронизации
reg PWRITE_MASTER = 0;  // сигнал, выбирающий режим записи или чтения (1 - запись, 0 - чтение)
wire PSEL;              // сигнал выбора периферии
reg [31:0] PADDR_MASTER = 0;  // адрес регистра
reg [31:0] PWDATA_MASTER = 0; // данные для записи в регистр
wire [31:0] PRDATA_MASTER; // данные, прочитанные из слейва
wire PENABLE; // сигнал разрешения, формирующийся в мастер APB
reg PRESET = 0; // сигнал сброса
wire PREADY;  // сигнал готовности (флаг того, что всё сделано успешно
wire [31:0] PADDR; // адрес, который мы будем передавать в слейв
wire [31:0] PWDATA;  // данные, которые будут передаваться в слейв
wire [31:0] PRDATA ;  // данные, прочитанные со слейва
wire PWRITE;  // сигнал записи или чтения на вход слейва


APB_master APB_master_1 (
.PCLK(PCLK),
.PWRITE_MASTER(PWRITE_MASTER),
.PSEL(PSEL),
.PADDR_MASTER(PADDR_MASTER),
.PWDATA_MASTER(PWDATA_MASTER),
.PRDATA_MASTER(PRDATA_MASTER),
.PENABLE(PENABLE),
.PRESET(PRESET),
.PREADY(PREADY),
.PADDR(PADDR),
.PWDATA(PWDATA),
.PRDATA(PRDATA),
.PWRITE(PWRITE)
);

Sum Sum_1 (
.PWRITE(PWRITE),
.PSEL(PSEL),
.PADDR(PADDR),
.PWDATA(PWDATA),
.PRDATA(PRDATA),
.PENABLE(PENABLE),
.PCLK(PCLK),
.PREADY(PREADY)
);

always #200 PCLK = ~PCLK; // генерация входного сигнала Pclk

// Тестовые сценарии
initial begin

    PCLK = 0;
    @(posedge PCLK);
    
    // Запись в регистр add_value
    PWRITE_MASTER = 1; // Выбираем запись
    PWDATA_MASTER = 32'd3; // Добавляем данные (32-х разрядное десятичное число 3)
    PADDR_MASTER = 0; // Выбираем адрес регистра "Добавляемое значение"
    @(posedge PCLK);
    @(posedge PCLK);


    // Производим сложение
    PWRITE_MASTER = 1; // Выбираем запись
    PWDATA_MASTER = 1; // Добавляем данные
    PADDR_MASTER = 4; // Выбираем адрес регистра "Контрольный регистр"
    @(posedge PCLK);
    @(posedge PCLK);

    // Чтение из регистра "Текущий результат" ( 0 0 0 0 + 0 0 1 1 = 0 0 1 1 = 3 )
    PWRITE_MASTER = 0;   // Выбираем чтение
    PADDR_MASTER = 8;    // Выбираем адрес регистра "Текущий результат"
    @(posedge PCLK);
    @(posedge PCLK);

    // Запись в регистр add_value
    PWRITE_MASTER = 1; // Выбираем запись
    PWDATA_MASTER = 32'd4; // Добавляем данные (32-х разрядное десятичное число 4)
    PADDR_MASTER = 0; // Выбираем адрес регистра "Добавляемое значение"
    @(posedge PCLK);
    @(posedge PCLK);

    // Производим сложение
    PWRITE_MASTER = 1; // Выбираем запись
    PWDATA_MASTER = 1; // Добавляем данные
    PADDR_MASTER = 4;  // Выбираем адрес регистра "Контрольный регистр"
    @(posedge PCLK);
    @(posedge PCLK);

    // Чтение из регистра "Текущий результат" ( 0 0 1 1 + 0 1 0 0 = 0 1 1 1 = 7 )
    PWRITE_MASTER = 0;   // Выбираем чтение
    PADDR_MASTER = 8;    // Выбираем адрес регистра "Текущий результат"
    @(posedge PCLK);
    @(posedge PCLK);

    // Запись в регистр add_value
    PWRITE_MASTER = 1; // Выбираем запись
    PWDATA_MASTER = 32'd9; // Добавляем данные (32-х разрядное десятичное число 9)
    PADDR_MASTER = 0; // Выбираем адрес регистра "Добавляемое значение"
    @(posedge PCLK);
    @(posedge PCLK);

    // Производим сложение
    PWRITE_MASTER = 1; // Выбираем запись
    PWDATA_MASTER = 1; // Добавляем данные
    PADDR_MASTER = 4;  // Выбираем адрес регистра "Контрольный регистр"
    @(posedge PCLK);
    @(posedge PCLK);

    // Чтение из регистра "Текущий результат" ( 0 1 1 1 + 1 0 0 1 = 1 1 1 1 = F )
    PWRITE_MASTER = 0;   // Выбираем чтение
    PADDR_MASTER = 8;    // Выбираем адрес регистра "Текущий результат"
    @(posedge PCLK);
    @(posedge PCLK);

    #500 $finish; // Заканчиваем симуляцию
end

initial begin
    $dumpfile("APB_master.vcd"); // создание файла для сохранения результатов симуляции
    $dumpvars(0, Sum_tb); // установка переменных для сохранения в файле
    $dumpvars;
end

endmodule
