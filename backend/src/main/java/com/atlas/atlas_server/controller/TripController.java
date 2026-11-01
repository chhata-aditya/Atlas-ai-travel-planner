package com.atlas.atlas_server.controller;

import com.atlas.atlas_server.dto.CreateTripRequest;
import com.atlas.atlas_server.dto.TripResponse;
import com.atlas.atlas_server.service.TripService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/trips")
public class TripController {

    private final TripService tripService;

    public TripController(TripService tripService) {
        this.tripService = tripService;
    }

    @GetMapping
    public ResponseEntity<List<TripResponse>> getMyTrips(Authentication authentication) {
        UUID userId = (UUID) authentication.getPrincipal();
        return ResponseEntity.ok(tripService.getUserTrips(userId));
    }

    @PostMapping
    public ResponseEntity<TripResponse> createTrip(
            Authentication authentication,
            @Valid @RequestBody CreateTripRequest request
    ) {
        UUID userId = (UUID) authentication.getPrincipal();
        TripResponse response = tripService.createTrip(userId, request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTrip(
            Authentication authentication,
            @PathVariable("id") UUID tripId
    ) {
        UUID userId = (UUID) authentication.getPrincipal();
        tripService.deleteTrip(userId, tripId);
        return ResponseEntity.noContent().build();
    }
}
