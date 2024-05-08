USE libreria;
CREATE TABLE ventas (
    idLibro VARCHAR(5),
    descuentoAplicado DECIMAL(5, 2),
    descuentoInformatica BOOLEAN DEFAULT NULL,
    precioFinal DECIMAL(5, 2),
    fechaHoraAdquisicion TIMESTAMP,
    FOREIGN KEY (idLibro) REFERENCES libro(book_id)
);