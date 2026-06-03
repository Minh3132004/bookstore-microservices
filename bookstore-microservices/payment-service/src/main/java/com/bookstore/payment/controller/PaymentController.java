package com.bookstore.payment.controller;

import com.bookstore.payment.dto.request.PayOSRequest;
import com.bookstore.payment.dto.response.ApiResponse;
import com.bookstore.payment.entity.Payment;
import com.bookstore.payment.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<Payment>>> getAllPaymentMethods() {
        return ResponseEntity.ok(paymentService.getAllPaymentMethods());
    }

    @PostMapping("/payos/create")
    public ResponseEntity<ApiResponse<String>> createPayOSLink(@RequestBody PayOSRequest request) {
        ApiResponse<String> response = paymentService.createPayOSLink(request);
        return response.isSuccess() ? ResponseEntity.ok(response) : ResponseEntity.badRequest().body(response);
    }

    @PostMapping("/payos/webhook")
    public ResponseEntity<String> handleWebhook(@RequestBody Object webhookData) {
        // Xử lý PayOS webhook callback
        return ResponseEntity.ok("OK");
    }
}
