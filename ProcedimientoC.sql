CREATE DEFINER=`admin`@`%` PROCEDURE `insertarVenta`(IN libro_id VARCHAR(5), OUT resultado VARCHAR(100))
    COMMENT 'PROCEDIMIENTO QUE AUTOMATICE LA FERIA DEL LIBRO'
BEGIN
    INSERT INTO ventas (idLibro, descuentoAplicado, descuentoInformatica, precioFinal, fechaHoraAdquisicion)
    SELECT 
        book_id,
        IF(book_price > (SELECT AVG(book_price) FROM libro), IF(cate_id='CA003', 0.10, 0.05), IF(cate_id='CA003', 0.05, 0)),
        IF(cate_id='CA003', TRUE, FALSE),
        IF(book_price > (SELECT AVG(book_price) FROM libro), IF(cate_id='CA003', (book_price*0.9)*0.95, book_price*0.95), IF(cate_id='CA003', book_price*0.95, book_price)),
        NOW()
    FROM libro
    WHERE book_id = libro_id;

    IF ROW_COUNT() = 1 THEN
        SET resultado = 'La venta del libro se ha insertado correctamente.';
    ELSE
        SET resultado = CONCAT('Error: Ocurrió un problema al insertar la venta del libro con el id ', libro_id);
    END IF;
END