package com.bookstore.order.dto.request;

import lombok.Data;

import java.util.List;

@Data
public class CreateOrderRequest {
    private String deliveryAddress;
    private String phoneNumber;
    private String fullName;
    private String note;
    private double totalPriceProduct;
    private double totalPrice;
    private int paymentId;
    private String paymentStatus;
    private List<OrderItemRequest> orderItems;

    @Data
    public static class OrderItemRequest {
        private int bookId;
        private int quantity;
    }
}
