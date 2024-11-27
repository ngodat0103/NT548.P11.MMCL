//package com.github.ngodat0103.usersvc;
//
//import com.github.javafaker.Faker;
//import com.github.ngodat0103.usersvc.persistence.document.Account;
//import com.github.ngodat0103.usersvc.persistence.repository.UserRepository;
//import java.time.Instant;
//import java.util.Locale;
//import lombok.AllArgsConstructor;
//import lombok.extern.slf4j.Slf4j;
//import org.bson.types.ObjectId;
//import org.springframework.boot.context.event.ApplicationReadyEvent;
//import org.springframework.context.ApplicationListener;
//import org.springframework.context.annotation.Configuration;
//import org.springframework.context.annotation.Profile;
//import org.springframework.core.task.SimpleAsyncTaskExecutor;
//import org.springframework.core.task.TaskExecutor;
//import org.springframework.security.crypto.password.PasswordEncoder;
//import reactor.core.publisher.Flux;
//import reactor.core.scheduler.Schedulers;
//
//// This class generates fake data for the test only, and does not include when Docker is used.
//
//@Configuration
//@AllArgsConstructor
//@Profile("dev")
//@Slf4j
//public class FakeDataGenerator implements ApplicationListener<ApplicationReadyEvent> {
//
//  private final UserRepository userRepository;
//  private static final Faker faker = new Faker();
//  private final PasswordEncoder passwordEncoder;
//  private final TaskExecutor taskExecutor = new SimpleAsyncTaskExecutor();
//
//  @Override
//  public void onApplicationEvent(ApplicationReadyEvent event) {
//    taskExecutor.execute(this::generateFakeData);
//  }
//
//  private void generateFakeData() {
//    int totalRecords = 50;
//    int batchSize = 50; // Adjust batch size for performance tuning
//
//    Flux.range(0, totalRecords)
//        .doOnSubscribe(subscription -> log.info("Starting fake data generation..."))
//        .buffer(batchSize)
//        .parallel(8)
//        .runOn(Schedulers.boundedElastic())
//        .log()
//        .map(batch -> batch.stream().map(i -> generateFakeAccount()).toList())
//        .flatMap(userRepository::saveAll)
//        .doOnComplete(() -> log.info("Fake data generation completed."))
//        .subscribe();
//  }
//
//  private Account generateFakeAccount() {
//    return Account.builder()
//        .accountId(new ObjectId().toHexString())
//        .nickName(faker.funnyName().name())
//        .email(faker.internet().emailAddress())
//        .password(passwordEncoder.encode(faker.internet().password(8, 30))) // Minimum 8 characters
//        .accountStatus(faker.options().option(Account.AccountStatus.class)) // Random status
//        .emailVerified(faker.bool().bool())
//        .zoneInfo(faker.address().timeZone())
//        .pictureUrl(faker.internet().avatar())
//        .locale(new Locale(faker.address().countryCode()))
//        .createdDate(Instant.now())
//        .lastUpdatedDate(Instant.now())
//        .build();
//  }
//}
