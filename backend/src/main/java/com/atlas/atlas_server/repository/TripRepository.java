package com.atlas.atlas_server.repository;

import com.atlas.atlas_server.entity.Trip;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TripRepository extends JpaRepository<Trip, UUID> {

    List<Trip> findByUserIdOrderByStartDateAsc(UUID userId);

    Optional<Trip> findByIdAndUserId(UUID id, UUID userId);

    @Query("SELECT t FROM Trip t WHERE t.user.id = :userId AND t.status != 'cancelled' AND t.startDate <= :endDate AND t.endDate >= :startDate")
    List<Trip> findClashingTrips(
            @Param("userId") UUID userId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );

    @Query("SELECT t FROM Trip t WHERE t.user.id = :userId AND t.id != :excludeTripId AND t.status != 'cancelled' AND t.startDate <= :endDate AND t.endDate >= :startDate")
    List<Trip> findClashingTripsExcluding(
            @Param("userId") UUID userId,
            @Param("excludeTripId") UUID excludeTripId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );
}
