CREATE DEFINER=`admin`@`%` PROCEDURE `precioMedioLibroEuros`(IN idLibro VARCHAR(5))
    COMMENT 'PROCEDIMIENTO QUE, PASADO EL IDENTIFICADOR DE UN LIBRO, TE MUESTRE POR PANTALLA SU PRECIO EN EUROS Y SI ESTÁ POR ENCIMA O POR DEBAJO DE LA MEDIA'
BEGIN
SELECT CONCAT(book_price,'€') AS precio_libro,
    IF(book_price=(SELECT AVG(book_price)FROM libro),'Precio en la media', IF(book_price > (SELECT AVG(book_price) FROM libro), 'Por encima de la media', 'Por debajo de la media')) AS rangoMedia
	FROM libro
	WHERE book_id = idLibro;
END