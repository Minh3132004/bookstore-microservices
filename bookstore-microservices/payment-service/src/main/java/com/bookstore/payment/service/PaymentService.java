package com.bookstore.payment.service;

import com.bookstore.payment.dto.request.PayOSRequest;
import com.bookstore.payment.dto.response.ApiResponse;
import com.bookstore.payment.entity.Payment;
import com.bookstore.payment.repository.PaymentRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import vn.payos.PayOS;
import vn.payos.type.CheckoutResponseData;
import vn.payos.type.ItemData;
import vn.payos.type.PaymentData;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final PayOS payOS;

    public ApiResponse<List<Payment>> getAllPaymentMethods() {
        return ApiResponse.success("OK", paymentRepository.findAll());
    }

    public ApiResponse<String> createPayOSLink(PayOSRequest request) {
        try {
            PaymentData paymentData = PaymentData.builder()
                    .orderCode(request.getOrderCode())
                    .amount(request.getAmount())
                    .description(request.getDescription())
                    .returnUrl(request.getReturnUrl())
                    .cancelUrl(request.getCancelUrl())
                    .buyerName(request.getBuyerName())
                    .buyerEmail(request.getBuyerEmail())
                    .buyerPhone(request.getBuyerPhone())
                    .items(List.of(
                            ItemData.builder()
                                    .name(request.getDescription())
                                    .price(request.getAmount())
                                    .quantity(1)
                                    .build()
                    ))
                    .build();

            CheckoutResponseData responseData = payOS.createPaymentLink(paymentData);
            log.info("PayOS link created for orderCode={}", request.getOrderCode());
            return ApiResponse.success("Tạo link thanh toán thành công!", responseData.getCheckoutUrl());
        } catch (Exception e) {
            log.error("PayOS error: {}", e.getMessage());
            return ApiResponse.error("Tạo link thanh toán thất bại: " + e.getMessage());
        }
    }
}
