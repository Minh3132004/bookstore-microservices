package com.bookstore.auth.service;

import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${app.mail-from}")
    private String mailFrom;

    @Async
    public void sendActivationEmail(String toEmail, String activationCode, String frontendUrl) {
        String url = frontendUrl + "/#/active-account?email=" + toEmail + "&code=" + activationCode;
        String subject = "Kích hoạt tài khoản BookStore";
        String body = "Cảm ơn bạn đã đăng ký! Vui lòng kích hoạt tài khoản:<br/>"
                + "<a href='" + url + "'>Nhấn vào đây để kích hoạt</a><br/>"
                + "Hoặc nhập mã: <strong>" + activationCode + "</strong>";
        sendHtmlEmail(toEmail, subject, body);
    }

    @Async
    public void sendForgotPasswordEmail(String toEmail, String tempPassword) {
        String subject = "Mật khẩu tạm thời - BookStore";
        String body = "Mật khẩu tạm thời của bạn là: <strong>" + tempPassword + "</strong>"
                + "<br/>Vui lòng đăng nhập và đổi mật khẩu ngay.";
        sendHtmlEmail(toEmail, subject, body);
    }

    private void sendHtmlEmail(String to, String subject, String htmlBody) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setFrom(mailFrom);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(htmlBody, true);
            mailSender.send(message);
            log.info("Email sent to {}", to);
        } catch (Exception e) {
            log.error("Failed to send email to {}: {}", to, e.getMessage());
        }
    }
}
