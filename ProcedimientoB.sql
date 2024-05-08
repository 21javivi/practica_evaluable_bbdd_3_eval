CREATE DEFINER=`admin`@`%` PROCEDURE `descuentoLibro`(IN idLibro VARCHAR(5))
    COMMENT 'PROCEDIMIENTO QUE APLIQUE DESCUENTOS AL PASAR UN ID DE LIBRO'
BEGIN
SELECT 
    book_name AS tituloLibro,
    CONCAT(book_price, '€') AS precioInicial,
    CONCAT(IF(book_price > (SELECT AVG(book_price) FROM libro), '10%', '5%')) AS descuentoAplicado, 
    IF(cate_id='CA003', '5%', '0%') AS descuentoInformatica,
    CONCAT(
        ROUND(
            IF(book_price > (SELECT AVG(book_price) FROM libro), 
                IF(cate_id='CA003', (book_price*0.9)*0.95, book_price*0.95),
                IF(cate_id='CA003', (book_price*0.95)*0.95, book_price)
            ), 2),'€') AS precioFinal
FROM libro
WHERE book_id = idLibro;

END