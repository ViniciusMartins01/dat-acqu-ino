CREATE DATABASE VaccinMonitorate;
USE VaccinMonitorate;

-- 1. Tabela Empresa (Adicionada para suportar a "visão consolidada de todas as unidades" e expansão) [3]
CREATE TABLE Empresa (
    idEmpresa INT PRIMARY KEY AUTO_INCREMENT,
    razaoSocial VARCHAR(100),
    cnpj CHAR(14) UNIQUE,
    telefone VARCHAR(15)
);

-- 2. Tabela Usuario (Com FK para Empresa) [2, 3]
CREATE TABLE Usuario (
    idUsuario INT PRIMARY KEY AUTO_INCREMENT,
    nomeCompleto VARCHAR(100),
    email VARCHAR(80) UNIQUE,
    senha VARCHAR(50),
    perfil VARCHAR(20),
    cpf CHAR(11) UNIQUE,
    fkEmpresa INT,
    CONSTRAINT chkPerfil CHECK (perfil IN ('Admin', 'Gerente', 'Operário')),
    CONSTRAINT fkUserEmpresa FOREIGN KEY (fkEmpresa) REFERENCES Empresa(idEmpresa)
);

-- 3. Tabela Transporte (Representa a Unidade/Caminhão refrigerado) [4, 5]
CREATE TABLE Transporte (
    idTransporte INT PRIMARY KEY AUTO_INCREMENT,
    placa VARCHAR(10) UNIQUE,
    modelo VARCHAR(50),
    tipoRefrigeramento VARCHAR(50),
    statusViagem VARCHAR(30) DEFAULT 'Trânsito',
    fkEmpresa INT,
    CONSTRAINT chkStatus CHECK (statusViagem IN ('Trânsito', 'Concluída', 'Cancelada')),
    CONSTRAINT fkTranspEmpresa FOREIGN KEY (fkEmpresa) REFERENCES Empresa(idEmpresa)
);

-- 4. Tabela Vacina (Relacionada ao Transporte para saber o que está sendo levado) [6]
CREATE TABLE Vacina (
    idVacina INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    fabricante VARCHAR(100),
    lote VARCHAR(50),
    temperaturaMin DECIMAL(4,2) DEFAULT 2.00, -- Padronizado conforme ANVISA [7]
    temperaturaMax DECIMAL(4,2) DEFAULT 8.00,
    fkTransporte INT,
    CONSTRAINT fkVacinaTransp FOREIGN KEY (fkTransporte) REFERENCES Transporte(idTransporte)
);

-- 5. Tabela Sensor (O sensor LM35 fica dentro do caminhão/transporte) [4, 8]
CREATE TABLE Sensor (
    idSensor INT PRIMARY KEY AUTO_INCREMENT,
    modelo VARCHAR(50) DEFAULT 'LM35',
    dataInstalacao DATE,
    fkTransporte INT,
    CONSTRAINT fkSensorTransp FOREIGN KEY (fkTransporte) REFERENCES Transporte(idTransporte)
);

-- 6. Tabela Monitoramento (Armazena capturas a cada 2 segundos) [1, 2]
CREATE TABLE Monitoramento (
    idMonitoramento INT PRIMARY KEY AUTO_INCREMENT,
    temperatura DECIMAL(5,2),
    dataHora DATETIME DEFAULT CURRENT_TIMESTAMP,
    fkSensor INT,
    CONSTRAINT fkDadoSensor FOREIGN KEY (fkSensor) REFERENCES Sensor(idSensor)
);

-- 7. Tabela Alerta (Vinculada ao monitoramento que gerou o desvio térmico) [1, 2]
CREATE TABLE Alerta (
    idAlerta INT PRIMARY KEY AUTO_INCREMENT,
    tipoAlerta VARCHAR(50), -- Ex: 'Crítico: Temperatura Alta'
    dataHora DATETIME DEFAULT CURRENT_TIMESTAMP,
    confirmacaoLeitura BOOLEAN DEFAULT FALSE, -- Requisito "Desejável" [2]
    fkMonitoramento INT,
    fkUsuarioConfirmacao INT, -- Quem visualizou o alerta [2]
    CONSTRAINT fkAlertaMonitor FOREIGN KEY (fkMonitoramento) REFERENCES Monitoramento(idMonitoramento),
    CONSTRAINT fkAlertaUser FOREIGN KEY (fkUsuarioConfirmacao) REFERENCES Usuario(idUsuario)
);