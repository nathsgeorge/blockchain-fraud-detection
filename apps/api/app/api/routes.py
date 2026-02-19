from fastapi import APIRouter, Depends

from app.domain.services.fraud_detection_service import FraudDetectionService
from app.schemas.fraud import FraudRequest, FraudResponse

router = APIRouter(prefix="/v1", tags=["fraud"])


def get_service() -> FraudDetectionService:
    return FraudDetectionService()


@router.post("/analyze", response_model=FraudResponse)
def analyze_wallet(payload: FraudRequest, service: FraudDetectionService = Depends(get_service)) -> FraudResponse:
    return service.analyze(payload)


@router.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}
