package com.atlas.atlas_server.service;

import com.atlas.atlas_server.dto.CreateTripRequest;
import com.atlas.atlas_server.dto.TripResponse;
import com.atlas.atlas_server.entity.Trip;
import com.atlas.atlas_server.entity.User;
import com.atlas.atlas_server.repository.TripRepository;
import com.atlas.atlas_server.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class TripService {

    private final TripRepository tripRepository;
    private final UserRepository userRepository;

    public TripService(TripRepository tripRepository, UserRepository userRepository) {
        this.tripRepository = tripRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public List<TripResponse> getUserTrips(UUID userId) {
        return tripRepository.findByUserIdOrderByStartDateAsc(userId)
                .stream()
                .map(TripResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional
    public TripResponse createTrip(UUID userId, CreateTripRequest request) {
        if (request.endDate().isBefore(request.startDate())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "End date cannot be before start date");
        }

        List<Trip> clashing = tripRepository.findClashingTrips(userId, request.startDate(), request.endDate());
        if (!clashing.isEmpty()) {
            Trip clash = clashing.get(0);
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "Date clash: You already have a booking for '" + clash.getTitle() + "' from "
                            + clash.getStartDate() + " to " + clash.getEndDate() + ". Please choose non-overlapping dates."
            );
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        Trip trip = Trip.builder()
                .user(user)
                .destinationId(request.destinationId())
                .destinationName(request.destinationName())
                .title(request.title())
                .startDate(request.startDate())
                .endDate(request.endDate())
                .status(request.status() != null && !request.status().isBlank() ? request.status() : "upcoming")
                .coverImageUrl(request.coverImageUrl())
                .build();

        Trip saved = tripRepository.save(trip);
        return TripResponse.fromEntity(saved);
    }

    @Transactional
    public void deleteTrip(UUID userId, UUID tripId) {
        Trip trip = tripRepository.findByIdAndUserId(tripId, userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Trip booking not found"));

        tripRepository.delete(trip);
    }
}
