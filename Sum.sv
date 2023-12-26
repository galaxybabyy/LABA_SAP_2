module Sum 
#(parameter add_value_ADDR = 4'h0,   // адрес регистра, в котором добавляемое значение
 parameter control_reg_ADDR = 4'h4, // адрес контрольного регистра
 parameter current_result_ADDR = 4'h8)   // адрес текущего значения
(
    input wire PCLK,             // Тактовый сигнал
    input wire PRESETn,          // Сигнал асинхронного сброса
    input wire PSEL,             // Сигнал выбора переферии 

    // Сигналы протокола APB
    input wire [31:0] PADDR,     // Адрес регистра
    input wire PENABLE,          // Сигнал разрешения чтения/записи
    output reg PREADY = 0,       // сигнал готовности (флаг того, что всё сделано успешно)
    input wire PWRITE,           // Сигнал записи/чтения
    input wire [31:0] PWDATA,    // Данные для записи
    output reg [31:0] PRDATA = 0 // Данные для чтения
);

// Регистры для записи значений
reg [31:0] add_value = 0;     // Регистр "Добавляемое значение"
reg [31:0] control_reg = 0;       // Регистр "Контрольный регистр"
reg [31:0] result_value = 0;        // Регистр "Текущий результат"

always @(posedge PCLK or posedge PSEL) 
begin
    if (PSEL && PENABLE && !PWRITE) begin // Чтение из регистров
    case(PADDR)
        add_value_ADDR: PRDATA <= add_value;
        control_reg_ADDR: PRDATA <= control_reg;
        current_result_ADDR: PRDATA <= result_value;
    endcase
    PREADY <= 1'd1; // Поднимаем флаг завершения операции
    end

    else if (PSEL && PENABLE && PWRITE) begin // Запись в регистры
    case(PADDR)
        add_value_ADDR: add_value <= PWDATA;
        control_reg_ADDR: control_reg <= PWDATA;
    endcase
    PREADY <= 1'd1; // Поднимаем флаг завершения операции
    end

    if (PREADY) // Сбрасываем PREADY после выполнения записи или чтения
    begin
        PREADY <= !PREADY;
    end

    if(control_reg) // Сбрасываем control_reg после выполнения операции сложения
    begin
        control_reg <= !control_reg; 
    end
end

always @(posedge control_reg) // Если поднят контрольный регистр, то складываем
begin
    result_value <= result_value | add_value; 
end

endmodule