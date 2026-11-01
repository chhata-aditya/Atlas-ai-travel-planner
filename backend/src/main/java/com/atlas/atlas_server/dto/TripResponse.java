package com.atlas.atlas_server.dto;

import com.atlas.atlas_server.entity.Trip;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

public record TripResponse(
        UUID id,
        UUID userId,
        UUID destinationId,
        String destinationName,
        String title,
        LocalDate startDate,
        LocalDate endDate,
        String status,
        String coverImageUrl,
        OffsetDateTime createdAt
) {
    public static TripResponse fromEntity(Trip trip) {
        return new TripResponse(
                trip.getId(),
                trip.getUser().getId(),
                trip.getDestinationId(),
                trip.getDestinationName(),
                trip.getTitle(),
                trip.getStartDate(),
                trip.getEndDate(),
                trip.getStatus(),
                trip.getCoverImageUrl(),
                trip.getCreatedAt()
        );
    }
}
