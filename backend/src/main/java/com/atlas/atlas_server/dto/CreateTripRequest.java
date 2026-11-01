package com.atlas.atlas_server.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.util.UUID;

public record CreateTripRequest(
        @NotBlank(message = "Trip title cannot be blank")
        String title,

        @NotBlank(message = "Destination name cannot be blank")
        String destinationName,

        UUID destinationId,

        @NotNull(message = "Start date is required")
        LocalDate startDate,

        @NotNull(message = "End date is required")
        LocalDate endDate,

        String status,

        String coverImageUrl
) {}
