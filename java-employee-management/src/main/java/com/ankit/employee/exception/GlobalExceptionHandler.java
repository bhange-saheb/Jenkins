package com.ankit.employee.exception;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
@RestControllerAdvice
public class GlobalExceptionHandler{
 @ExceptionHandler(EmployeeNotFoundException.class)
 public ResponseEntity<Map<String,String>> handle(EmployeeNotFoundException ex){
  return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error",ex.getMessage()));
 }
}
